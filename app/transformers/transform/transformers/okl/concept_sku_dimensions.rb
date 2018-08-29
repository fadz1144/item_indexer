module Transform
  module Transformers
    module OKL
      class ConceptSkuDimensions < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuDimensionsRevision'
        attribute :sku_id, association: :sku
        attribute :source_sku_id, association: :sku

        exclude :concept_sku_id

        module Decorations
          include Transform::Transformers::DimensionDisplay

          def concept_id
            CONCEPT_ID
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end

          def source_updated_at
            super || '1976-07-06'.to_datetime
          end

          def source_created_by
            super || 0
          end

          def source_updated_by
            super || 0
          end
        end
      end
    end
  end
end
