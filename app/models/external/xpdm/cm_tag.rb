module External
  module XPDM
    class CMTag < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_cm_frfm'
      self.primary_key = 'pdm_object_id'
      attribute :cm_tag_free_frm_txt, :xpdm_string
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :cm_tags

      default_scope { where('trim(cm_tag_free_frm_txt) is not null') }
    end
  end
end
