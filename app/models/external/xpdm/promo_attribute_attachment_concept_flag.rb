module External
  module XPDM
    class PromoAttributeAttachmentConceptFlag < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_promo_web'
      belongs_to :item, class_name: 'External::XPDM::Item', foreign_key: 'pdm_object_id'
      include Concept
      attribute :promo_vld_status_ind, :xpdm_boolean_ind
    end
  end
end
