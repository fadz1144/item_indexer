module External
  module XPDM
    class WebCost < External::XPDM::Base
      self.table_name = 'pdm_item_cst_retl_web_cst'
      self.primary_key = 'pdm_object_id'
      include External::XPDM::Concept
      alias_attribute :web_site_cd, :site_id
    end
  end
end
