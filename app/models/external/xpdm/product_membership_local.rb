module External
  module XPDM
    # Product Membership Local
    #
    # The Product Membership Local model represents XPMD data but is stored locally. The remote table does not have an
    # index that supports going from skus to products, so the table is replicated locally. The two models are
    # interchangeable.
    class ProductMembershipLocal < ApplicationRecord
      self.table_name = 'xpdm_product_memberships'

      with_options primary_key: :pdm_object_id do
        belongs_to :product, class_name: 'External::XPDM::Product', foreign_key: :pdm_object_id
        belongs_to :sku, class_name: 'External::XPDM::Sku', foreign_key: :item_code_name_cd
      end

      # the membership is at the product, not concept level; restrict to BBBY so there's only one
      belongs_to :concept_product, -> { where(concept_id: 1) },
                 class_name: 'CatModels::ConceptProduct',
                 primary_key: :source_product_id,
                 foreign_key: :pdm_object_id
    end
  end
end
