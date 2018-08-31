module Transform
  module Transformers
    module OKL
      class ConceptSkuPricing < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        attribute :retail_price, source_name: :price
        exclude :concept_sku_id

        module Decorations
          include Transform::Transformers::Margin

          def concept_id
            CONCEPT_ID
          end
        end
      end
    end
  end
end
