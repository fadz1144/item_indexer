module Transform
  module Transformers
    module OKL
      class ConceptSkuImage < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuImageRevision'
        belongs_to :sku_image

        attribute :sku_image_id, source_name: :image_id
        attribute :source_sku_image_id, source_name: :image_id

        exclude :concept_sku_id, :primary_sku_image

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          def image_url
            "https://okl.scene7.com/is/image/#{resource_folder}/#{resource_name}"
          end
        end
      end
    end
  end
end
