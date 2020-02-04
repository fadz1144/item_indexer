module External
  module XPDM
    class ItemVendor < External::XPDM::Base
      self.table_name = 'pdm_item_prmry_vdr_info'
      self.primary_key = 'pdm_object_id'
      default_scope { by_vdr_num.by_newest }
      scope :vdr_num_not_zero, -> { where.not(pmry_vdr_num: 0) }
      scope :by_newest, -> { order('update_ts DESC') }
      scope :by_vdr_num, -> { order('pmry_vdr_num DESC') }

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
