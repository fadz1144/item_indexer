module CatalogMessage
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :_associations
      self._associations = []
    end

    # Associations allow message classes to define layouts for nested data. Each association is a message itself and
    # receives the same specifications that a class-defined message receives, plus the key that the data is nested
    # under.
    module ClassMethods
      # Specifies that each message includes a child with a single row of data.
      #
      # * name: the key that the child data is nested under
      # * model_name: the name of the model class used to persist the message data
      #
      # == Options
      # * attribute_mapping: a hash to map attribute names from the message to the model
      # * class_name: if the message cannot be represented by the base class, pass in the class that specifies it
      # * propagate: copy attribute (or attributes) from parent message to child
      def has_one(name, model_name:, **options) # rubocop:disable Style/PredicateName
        _associations << SingleRecordAssociation.build(name, model_name, options)
      end

      # Specifies that each message includes a child with one or more rows of data.
      # See has_one for parameters.
      def has_many(name, model_name:, **options) # rubocop:disable Style/PredicateName
        _associations << MultipleRecordAssociation.build(name, model_name, options)
      end

      def inherited(subclass)
        subclass._associations = _associations.clone
      end
    end

    def children
      return [] if _associations.nil?
      _associations.map { |a| a.new(self) }
    end

    class AbstractRecordAssociation < CatalogMessage::Base
      class_attribute :_data_key, instance_writer: false, instance_predicate: false
      class_attribute :_propagate, instance_writer: false, instance_predicate: false

      def self.build(key, model_name, options)
        Class.new(self) do
          model_name model_name
          self._data_key = key.to_s
          attribute_mapping options[:attribute_mapping] if options.key?(:attribute_mapping)
          self._propagate = [options[:propagate]].flatten if options.key?(:propagate)
        end
      end

      def initialize(parent_message)
        @data = parent_message.data_attributes[_data_key] || {}
        propagate(parent_message.data_attributes.slice(*attributes_to_propagate(parent_message._propagate_down)))
      end

      private

      def attributes_to_propagate(propagate_down)
        (propagate_down || []) + (_propagate || [])
      end

      def propagate(prop_data)
        @data.merge!(prop_data)
      end
    end

    class SingleRecordAssociation < AbstractRecordAssociation
    end

    class MultipleRecordAssociation < AbstractRecordAssociation
      def records
        @data.map { |child_data| to_active_record(child_data) } + children.flat_map(&:records)
      end

      private

      def propagate(prop_data)
        @data.each { |r| r.merge!(prop_data) }
      end
    end
  end
end
