module Transform
  module Transformers
    module XPDM
      class RelatedItem < CatalogTransformer::Base
        source_name 'External::XPDM::RelatedItem'
        attribute :collection_id, association: :collection, source_name: :pdm_object_id
        attribute :like_unlike_flag, source_name: :like_unlike_flag
      end
    end
  end
end
