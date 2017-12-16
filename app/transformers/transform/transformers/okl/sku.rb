module Transform
  module Transformers
    module OKL
      class Sku < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        has_many :product_memberships, match_keys: [:sku_id]
        attribute :sku_id, source_name: :sku_id
        attribute :gtin, source_name: :upc

        references :brand, association: :concept_brand
        references :category, association: :concept_category

        exclude allow_primary_key: true

        module Decorations
          def image_count
            images.size
          end
        end
      end
    end
  end
end
