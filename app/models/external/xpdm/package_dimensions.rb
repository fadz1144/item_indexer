module External
  module XPDM
    class PackageDimensions < External::XPDM::Base
      self.table_name = 'pdm_item_pkg_dmnsn'
      self.primary_key = 'pdm_object_id'
      belongs_to :sku, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :package_dimensions
    end
  end
end
