module Transform
  module Transformers
    module XPDM
      class ProductMembership < CatalogTransformer::Base
        source_name 'External::XPDM::ProductMembership'
        references :product, association: :concept_product
        exclude :sku_id

        # enables the source product Id to be used as the match key
        def attribute_values
          super.merge('product_id' => @source.concept_product.product.product_id)
        end
      end
    end
  end
end
