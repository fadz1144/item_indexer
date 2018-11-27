module Transform
  module Transformers
    module XPDM
      class CollectionMembership < CatalogTransformer::Base
        source_name 'External::XPDM::CollectionMembership'
        attribute :sort_order, source_name: :rlate_item_dsply_seq_num
        references :product, association: :concept_product
        exclude :collection_id

        # enables the source product Id to be used as the match key
        def attribute_values
          super.merge('product_id' => @source.concept_product&.product&.product_id)
        end
      end
    end
  end
end
