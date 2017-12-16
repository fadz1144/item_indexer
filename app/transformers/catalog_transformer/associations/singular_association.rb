module CatalogTransformer
  module Associations
    class SingularAssociation < CatalogTransformer::Associations::Base
      def handler_class
        CatalogTransformer::Associations::SingularHandler
      end
    end
  end
end
