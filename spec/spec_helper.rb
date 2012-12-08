require 'pp'
require 'ostruct'
require 'dm-mapper'
require 'virtus'

require 'data_mapper/engine/veritas'

require 'rspec'

%w(shared support).each do |name|
  Dir[File.expand_path("../#{name}/**/*.rb", __FILE__)].each { |file| require file }
end

RSpec.configure do |config|

  config.before(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      # TODO Find out why this is necessary since renaming RelationRegistry => Relation
      DataMapper::Mapper.instance_variable_set(:@registry, nil)
      @test_env = TestEnv.instance
    end
  end

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      @test_env.clear!
    end
  end

  def mock_model(*args)
    @test_env.mock_model(*args)
  end

  def mock_mapper(*args)
    @test_env.mock_mapper(*args)
  end

  def subclass(name = nil)
    Class.new(described_class) do
      define_singleton_method(:name) { "#{name}" }
      yield if block_given?
    end
  end

  def mock_attribute(name, type, options = {})
    Mapper::Attribute.build(name, options.merge(:type => type))
  end

  def mock_relation(name, header = [])
    Veritas::Relation::Base.new(name, header)
  end

  def mock_relationship(name, attributes = {})
    Relationship::OneToMany.new(name, attributes[:source_model], attributes[:target_model], attributes)
  end

  def mock_connector(attributes)
    OpenStruct.new(attributes)
  end

  def mock_node(name)
    OpenStruct.new(:name => name)
  end

  def mock_join_definition(left_relation, right_relation, left_keys, right_keys)
    left  = Relationship::JoinDefinition::Side.new(left_relation,  left_keys)
    right = Relationship::JoinDefinition::Side.new(right_relation, right_keys)
    Relationship::JoinDefinition.new(left, right)
  end

  def unary_aliases(field_map, original_aliases)
    Relation::Graph::Node::Aliases::Unary.new(field_map, original_aliases)
  end

  class TestEngine < DataMapper::Engine::Veritas::Engine
    def initialize(uri)
      @relations = DataMapper::Relation::Graph.new(self)
    end
  end

  TEST_ENGINE = TestEngine.new('db://localhost/test')
  DataMapper.engines[:test] = TEST_ENGINE
end

include DataMapper
