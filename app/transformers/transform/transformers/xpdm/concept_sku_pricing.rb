module Transform
  module Transformers
    module XPDM
      class ConceptSkuPricing < CatalogTransformer::Base
        source_name 'External::XPDM::Sku'
        attribute :sku_id, source_name: :pdm_object_id
        attribute :source_sku_id, source_name: :pdm_object_id
        attribute :retail_price, source_name: :price
        references :concept

        exclude :concept_sku_id, :pre_markdown_price, :map_price, :contribution_margin_amount,
                :contribution_margin_percent

        module Decorations
          include Transform::Transformers::Margin
        end
      end
    end
  end
end
