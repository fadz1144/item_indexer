module CatalogMessage
  module Associations
    extend ActiveSupport::Concern

    included do
      class_attribute :associations
      self.associations = []
    end

    # Associations allow message classes to define layouts for nested data. Each association is a message itself and
    # receives the same specifications that a class-defined message receives, plus the key that the data is nested
    # under.
    module ClassMethods
      # Specifies that each message includes a child with a single row of data.
      #
      # * name: the name of the association as defined in the ActiveRecord
      # * source_name: the key that the child data is nested under
      #
      # == Options
      # * attribute_mapping: a hash to map attribute names from the message to the model
      # * source_name: the message key for the data
      # * propagate: copy attribute (or attributes) from parent message to child
      def has_one(name, source_name: nil, **options) # rubocop:disable Style/PredicateName
        associations << SingularAssociation.build(self, name, source_name, options)
      end

      # Specifies that each message includes a child with one or more rows of data.
      # See has_one for parameters.
      def has_many(name, source_name: nil, **options) # rubocop:disable Style/PredicateName
        associations << CollectionAssociation.build(self, name, source_name, options)
      end

      def inherited(subclass)
        subclass.associations = associations.clone
      end
    end

    def children(parent)
      return [] if associations.nil?
      associations.map { |a| a.new(self, parent) }
    end

    class AbstractRecordAssociation < CatalogMessage::Base
      class_attribute :parent_class, instance_writer: false, instance_predicate: false
      class_attribute :data_key, instance_writer: false, instance_predicate: false
      class_attribute :association_name, instance_writer: false, instance_predicate: false
      class_attribute :propagate, instance_accessor: false, instance_predicate: false

      def self.build(parent_class, name, data_key, options)
        Class.new(self) do
          self.parent_class = parent_class
          self.association_name = name
          self.data_key = data_key&.to_s || name.to_s
          attribute_mapping options[:attribute_mapping] if options.key?(:attribute_mapping)
          self.propagate = [options[:propagate]].flatten if options.key?(:propagate)
        end
      end

      def self.model_name
        association = parent_class.model_class.reflect_on_association(association_name)
        if association.nil?
          raise CatalogMessage::Errors::AssociationNotDefined.new(parent_class.model_class, association_name)
        end
        association.class_name
      end

      def initialize(parent_message, parent_record)
        @data = read_data_from_parent(parent_message)
        return if @data.empty?

        propagate_parent(parent_message.data_attributes.slice(*attributes_to_propagate(parent_message)))
        @parent_record = parent_record
      end

      private

      def read_data_from_parent(parent_message)
        parent_message.data_attributes[data_key] || {}
      end

      def attributes_to_propagate(parent_message)
        (parent_message.class.propagate || []) + (self.class.propagate || [])
      end

      def propagate_parent(prop_data)
        @data.merge!(prop_data)
      end
    end

    class SingularAssociation < AbstractRecordAssociation
      def records
        @data.empty? ? [] : super
      end

      private

      def read_data_from_parent(parent_message)
        # enables child record to be created from single message row
        return parent_message.data_attributes if data_key == 'self'
        super
      end

      def to_active_record
        @parent_record.public_send("build_#{association_name}", modelized_attributes)
      end
    end

    class CollectionAssociation < AbstractRecordAssociation
      def data_attributes
        @child_data
      end

      def records
        @data.flat_map do |child_data|
          @child_data = child_data
          super
        end
      end

      private

      def to_active_record
        @parent_record.public_send(association_name).build(modelized_attributes)
      end

      def propagate_parent(prop_data)
        @data.each { |r| r.merge!(prop_data) }
      end
    end
  end
end
