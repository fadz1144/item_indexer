module External
  module XPDM
    class Logistics < External::XPDM::Base
      self.table_name = 'pdm_item_lgstcs_info'
      INCLUDED_COLUMNS = %w[pdm_object_id
                            vdc_ind
                            vdc_min_day_to_shp
                            vdc_max_day_to_shp].freeze
      default_scope -> { select(INCLUDED_COLUMNS) }
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :logistics
    end
  end
end
