module Transform
  module Transformers
    module OKL
      class SkuImage < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuImageRevision'

        attribute :sku_image_id, source_name: :image_id
        references :sku, association: :sku, source_name: :polished_sku

        module Decorations
          def image_url
            "https://okl.scene7.com/is/image/#{resource_folder}/#{resource_name}"
          end
        end
      end
    end
  end
end
