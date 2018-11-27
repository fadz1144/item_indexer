module External
  module XPDM
    class CollectionMembership < External::XPDM::ItemRelation
      default_scope { where(rltn_type: 'Collection_to_WebProduct') }

      with_options primary_key: :pdm_object_id do
        belongs_to :collection, class_name: 'External::XPDM::Collection', foreign_key: :pdm_object_id
        belongs_to :product, class_name: 'External::XPDM::Product', foreign_key: :item_code_name_cd
      end

      # the membership is at the product, not concept level; restrict to BBBY so there's only one
      belongs_to :concept_product, -> { where(concept_id: 1) },
                 class_name: 'CatModels::ConceptProduct',
                 primary_key: :source_product_id,
                 foreign_key: :item_code_name_cd
    end
  end
end
