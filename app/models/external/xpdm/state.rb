module External
  module XPDM
    class State < External::XPDM::Base
      self.table_name = 'pdm_item_prod_info_web'
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :states
    end
  end
end
