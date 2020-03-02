module Transform
  module Transformers
    module XPDM
      class ConceptProductImage < CatalogTransformer::Base
        source_name 'External::XPDM::Image'
        attribute :primary_image, source_name: :primary
        attribute :source_product_image_id, source_name: :image_asset_id

        exclude :concept_product_id, :product_image_id

        after_transform do |target|
          target.build_product_image(product: target.concept_product.product) if target.product_image_id.nil?
          target.product_image.image_url = target.image_url
        end

        module Decorations
          include Transform::Transformers::XPDM::SharedConceptImages
        end
      end
    end
  end
end
