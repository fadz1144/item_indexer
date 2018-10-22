module CatalogTransformer
  module Associations
    class SingularAssociation < CatalogTransformer::Associations::Base
      private

      def handler_class
        CatalogTransformer::Associations::SingularHandler
      end
    end
  end
end
