module CatalogTransformer
  module Associations
    class CollectionAssociation < CatalogTransformer::Associations::Base
      def handler_class
        CatalogTransformer::Associations::CollectionHandler
      end
    end
  end
end
