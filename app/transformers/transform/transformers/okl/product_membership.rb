module Transform
  module Transformers
    module OKL
      class ProductMembership < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        references :product, association: :concept_product

        # enables the source product Id to be used as the match key
        def attribute_values
          super.merge('product_id' => @source.concept_product&.product&.product_id)
        end
      end
    end
  end
end
