module External
  module XPDM
    class Brand < External::XPDM::Base
      self.table_name = 'pdm_lu_brand'
      self.primary_key = 'brand_cd'
      attribute :brand_name, :xpdm_string

      def valid?
        brand_name.present? && !brand_cd.to_i.zero?
      end
    end
  end
end
