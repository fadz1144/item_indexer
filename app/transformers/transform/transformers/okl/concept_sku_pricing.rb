module Transform
  module Transformers
    module OKL
      class ConceptSkuPricing < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        attribute :retail_price, source_name: :price
        exclude :concept_sku_id

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          # TODO: the margin calc's should be on the model in cat_models so that they work for all sources
          def margin_amount
            return nil unless price.present? && cost.present? && price > cost
            price - cost
          end

          def margin_percent
            return nil unless margin_amount.present? && !price.zero?
            margin_amount / price
          end
        end
      end
    end
  end
end
