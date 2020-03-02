module Transform
  module Transformers
    module XPDM
      class ConceptCollectionImage < CatalogTransformer::Base
        source_name 'External::XPDM::Image'
        attribute :primary_image, source_name: :primary
        attribute :source_collection_image_id, source_name: :image_asset_id

        exclude :concept_collection_id, :collection_image_id

        after_transform do |target|
          if target.collection_image_id.nil?
            target.build_collection_image(collection: target.concept_collection.collection)
          end
          target.collection_image.image_url = target.image_url
        end

        module Decorations
          include Transform::Transformers::XPDM::SharedConceptImages
        end
      end
    end
  end
end
