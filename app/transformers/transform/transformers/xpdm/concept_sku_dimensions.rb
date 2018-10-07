module Transform
  module Transformers
    module XPDM
      class ConceptSkuDimensions < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptSku'
        attribute :sku_id, source_name: :pdm_object_id
        attribute :source_sku_id, source_name: :pdm_object_id

        exclude :concept_sku_id

        module Decorations
          include Transform::Transformers::DimensionDisplay
        end
      end
    end
  end
end
