module External
  module XPDM
    class ItemVendor < External::XPDM::Base
      self.table_name = 'pdm_item_prmry_vdr_info'
      self.primary_key = 'pdm_object_id'
      default_scope -> { where.not(pmry_vdr_num: 0) }
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :item_vendor
      belongs_to :concept_vendor, -> { where(concept_id: 99) },
                 optional: true,
                 class_name: 'CatModels::ConceptVendor',
                 primary_key: :source_vendor_id,
                 foreign_key: :pmry_vdr_num

      attribute :pmry_vdr_part_modl_num, :xpdm_string
    end
  end
end
