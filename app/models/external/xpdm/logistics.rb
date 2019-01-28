module External
  module XPDM
    class Logistics < External::XPDM::Base
      self.table_name = 'pdm_item_lgstcs_info'
      INCLUDED_COLUMNS = %w[pdm_object_id
                            vdc_ind
                            vdc_min_day_to_shp
                            vdc_max_day_to_shp
                            ltl_item_ind
                            cstmzn_type_cd
                            cstmzn_type_name].freeze

      # CSTMZN_TYPE_CD | CSTMZN_TYPE_NAME
      # N              | Customization not available
      # U              | UNKNOWN
      CONSIDERED_NOT_PERSONALIZABLE = %w[N U].freeze

      default_scope -> { select(INCLUDED_COLUMNS) }
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :logistics
      attribute :vdc_ind, :xpdm_boolean_ind
      attribute :ltl_item_ind, :xpdm_boolean_ind

      def personalizable?
        cstmzn_type_cd.present? && !CONSIDERED_NOT_PERSONALIZABLE.include?(cstmzn_type_cd)
      end
    end
  end
end
