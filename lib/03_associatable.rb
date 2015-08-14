require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||
                   (self_class_name.to_s.underscore + "_id").to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      target_class = options.model_class
      foreign_key  = options.foreign_key
      primary_key  = options.primary_key
      target_class.where(primary_key => attributes[foreign_key]).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      target_class = options.model_class
      foreign_key = options.send(:foreign_key)
      primary_key = options.send(:primary_key)
      target_class.where(foreign_key => attributes[primary_key])
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @options ||= {}
  end
end

class SQLObject
  extend Associatable
end
