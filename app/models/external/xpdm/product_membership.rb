module External
  module XPDM
    class ProductMembership < External::XPDM::ItemRelation
      default_scope { where(rltn_type: 'WebProduct_to_SKU') }

      with_options primary_key: :pdm_object_id do
        belongs_to :product, class_name: 'External::XPDM::Product', foreign_key: :pdm_object_id
        belongs_to :sku, class_name: 'External::XPDM::Sku', foreign_key: :item_code_name_cd
      end

      # the membership is at the product, not concept level; restrict to BBBY so there's only one
      belongs_to :concept_product, -> { where(concept_id: 1) },
                 class_name: 'CatModels::ConceptProduct',
                 primary_key: :source_product_id,
                 foreign_key: :pdm_object_id

      # subset for testing
      def self.modulo(divisor = 10, modulus = 1)
        p = arel_table.name
        where("mod(#{p}.pdm_object_id, #{divisor}) = #{modulus}")
      end
    end
  end
end
