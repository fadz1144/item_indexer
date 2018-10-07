module External
  module XPDM
    class Vendor < External::XPDM::Base
      self.table_name = 'pdm_lu_vendor'
      self.primary_key = 'vendor_num'
      attribute :vendor_name, :xpdm_string
    end
  end
end
