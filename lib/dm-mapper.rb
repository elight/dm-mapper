module DataMapper

  # Represent an undefined argument
  Undefined = Object.new.freeze

  # @api public
  def self.[](model)
    Mapper[model]
  end

  # @api public
  def self.mapper_registry
    Mapper.mapper_registry
  end

  # @api public
  def self.relation_registry
    Mapper.relation_registry
  end

  # @api public
  def self.setup(name, uri)
    adapters[name.to_sym] = Veritas::Adapter::DataObjects.new(uri)
  end

  # @api public
  def self.setup_gateway(repository, relation)
    gateway = Veritas::Relation::Gateway.new(adapters[repository], relation)
    Mapper.relation_registry << gateway
  end

  # @api public
  def self.setup_relation_gateway(repository, name, header)
    setup_gateway(repository, base_relation(name, header))
  end

  # @api public
  def self.base_relation(name, header)
    Veritas::Relation::Base.new(name, header)
  end

  # @api public
  def self.adapters
    @adapters ||= {}
  end

  # @api public
  #
  # TODO: implement handling of dependencies between mappers
  def self.finalize
    mappers = Mapper.descendants

    mappers.each { |mapper| mapper.finalize }
    mappers.each { |mapper| mapper.finalize_attributes }
    mappers.each { |mapper| mapper.finalize_relationships }

    self
  end
end # module DataMapper

require 'veritas'
require 'veritas-optimizer'
require 'virtus/support/descendants_tracker'

require 'data_mapper/support/utils'
require 'data_mapper/support/inflector/inflections'
require 'data_mapper/support/inflector/methods'
require 'data_mapper/support/inflections'

require 'data_mapper/relation_registry'
require 'data_mapper/mapper_registry'
require 'data_mapper/relationship/dsl'

require 'data_mapper/mapper/relationship_set'
require 'data_mapper/mapper/attribute'
require 'data_mapper/mapper/attribute/primitive'
require 'data_mapper/mapper/attribute/mapper'
require 'data_mapper/mapper/attribute/collection'
require 'data_mapper/mapper/attribute_set'
require 'data_mapper/mapper'
require 'data_mapper/mapper/relation'
require 'data_mapper/mapper/relation/base'

require 'data_mapper/relationship'
require 'data_mapper/relationship/options'
require 'data_mapper/relationship/options/one_to_one'
require 'data_mapper/relationship/options/one_to_many'
require 'data_mapper/relationship/options/many_to_one'
require 'data_mapper/relationship/options/many_to_many'
require 'data_mapper/relationship/one_to_one'
require 'data_mapper/relationship/one_to_many'
require 'data_mapper/relationship/many_to_one'
require 'data_mapper/relationship/many_to_many'
require 'data_mapper/relationship/builder'
require 'data_mapper/relationship/builder/collection_behavior'
require 'data_mapper/relationship/builder/one_to_one'
require 'data_mapper/relationship/builder/one_to_many'
require 'data_mapper/relationship/builder/many_to_one'
require 'data_mapper/relationship/builder/many_to_many'

require 'data_mapper/query'
