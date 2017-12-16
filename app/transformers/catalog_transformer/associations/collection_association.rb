module CatalogTransformer
  module Associations
    class CollectionAssociation < CatalogTransformer::Associations::Base
      attr_reader :match_keys

      def initialize(name, source_name, transformer_name, match_keys)
        super(name, source_name, transformer_name)
        @match_keys = [match_keys].flatten
      end

      def handler_class
        CatalogTransformer::Associations::CollectionHandler
      end
    end
  end
end
