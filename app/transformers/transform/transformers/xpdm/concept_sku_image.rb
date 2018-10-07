module Transform
  module Transformers
    module XPDM
      class ConceptSkuImage < CatalogTransformer::Base
        source_name 'External::XPDM::Image'
        attribute :primary_sku_image, source_name: :primary
        attribute :source_sku_image_id, source_name: :image_asset_id

        exclude :concept_sku_id, :sku_image_id

        after_transform do |target|
          target.build_sku_image(sku: target.concept_sku.sku) if target.sku_image_id.nil?
          target.sku_image.image_url = target.image_url
        end

        module Decorations
          def primary
            alt_index.zero?
          end

          def concept_id
            99
          end

          def hosting_service
            'Scene7'.freeze
          end

          def resource_folder
            'BedBathandBeyond'.freeze
          end

          def sort_order
            (alt_index + 1) * 1_000
          end
        end
      end
    end
  end
end
