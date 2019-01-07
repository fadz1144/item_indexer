module CatalogTransformer
  module Associations
    class CollectionAssociation < CatalogTransformer::Associations::Base
      def initialize(name, source_name, transformer_name, match_keys, partial)
        super(name, source_name, transformer_name, match_keys)
        @partial = partial
      end

      def handler_for(source, target)
        handler_class.new(source, target, @partial)
      end

      private

      def default_source_name
        @name
      end

      def handler_class
        CatalogTransformer::Associations::CollectionHandler
      end
    end
  end
end
