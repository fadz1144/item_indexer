module External
  module XPDM
    class WebPrice < External::XPDM::Base
      self.table_name = 'pdm_item_cst_retl_web'
      self.primary_key = 'pdm_object_id'
      include External::XPDM::Concept
    end
  end
end
