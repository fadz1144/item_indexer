module External
  module XPDM
    class AssemblyDimensions < External::XPDM::Base
      self.table_name = 'pdm_item_asmbl_dmnsn_info'
      self.primary_key = 'pdm_object_id'
      belongs_to :sku, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :assembly_dimensions
    end
  end
end
