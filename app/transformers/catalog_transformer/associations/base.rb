module CatalogTransformer
  module Associations
    class Base
      attr_reader :name, :parent_key
      def initialize(name, source_name, transformer_name, parent_key = nil)
        @name = name
        @source_name = source_name
        @transformer_name = transformer_name
        @parent_key = parent_key
      end

      def source_name
        @source_name || :itself
      end

      def source_includes
        nested = transformer_class.source_includes.flatten

        if @source_name.present?
          nested.present? ? { @source_name => nested } : @source_name
        else
          nested.presence
        end
      end

      def target_includes
        nested = transformer_class.target_includes
        nested.empty? ? @name : { @name => nested }
      end

      def transformer_class
        @transformer_name.constantize
      end
    end
  end
end
