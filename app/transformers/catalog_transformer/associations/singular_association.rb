module CatalogTransformer
  module Associations
    class SingularAssociation < CatalogTransformer::Associations::Base
      private

      def default_source_name
        :itself
      end

      def handler_class
        CatalogTransformer::Associations::SingularHandler
      end
    end
  end
end
