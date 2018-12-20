module CatalogTransformer
  module Attributes
    # = Attribute
    #
    # An Attribute is used to specify the information required to populate the target model. Attributes are created in
    # one of the following manners:
    # - all matching attribute names on the source and target models have attributes generated
    # - the transformer class can generate an attribute to be populated by invoking the <tt>attribute</tt> class method
    # - all belongs to associations on the target that are listed as associations have reference attribute generated
    # - the transformer class can generate a reference attribute by invoking the <tt>refrences</tt> class method
    #
    # The <tt>attribute</tt> method is used to specify additional information about an attribute when one of the
    # following is true:
    # - the attribute names are not the same on the source and target models
    # - the value comes from an association on the source
    # - a default value should be specified
    #
    # == Examples
    #
    # The target attribute name is description but the source attribute name is long_descr
    #   attribute :description, source_name: :long_descr
    #
    # The target attribute description comes from the source association details
    #   attribute :description, association: :details
    #
    # The target attribute description comes from the source association details and is named long_descr
    #   attribute :description, association: :details, source_name: :long_descr

    # The target attribute in_stock comes from the source association inventory and has a default of false
    #   attribute :in_stock, association: :inventory, default_value: false
    class Attribute
      attr_reader :default_value

      def initialize(name, options = {})
        @name = name
        @association = options[:association]
        @source_name = options[:source_name]
        @default_value = options[:default_value]
      end

      # used as the key in assign_attributes, must be a string
      def name
        @name.to_s
      end

      def source_name
        @source_name || @name
      end

      def source_record_name
        @association || :itself
      end

      # attributes never have target includes; otherwise it would be an Association or a ReferenceAttribute
      def target_includes
        nil
      end

      def source_includes
        @association.presence
      end
    end
  end
end
