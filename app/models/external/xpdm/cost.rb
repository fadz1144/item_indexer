module External
  module XPDM
    class Cost < External::XPDM::Base
      INCLUDED_COLUMNS = %w[pdm_object_id
                            map_prc_amt].freeze

      default_scope -> { select(INCLUDED_COLUMNS) }

      self.table_name = 'pdm_item_cst_retl'
      self.primary_key = 'pdm_object_id'

      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :cost
    end
  end
end
