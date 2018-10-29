module External
  module XPDM
    class Compliance < External::XPDM::Base
      self.table_name = 'pdm_item_trd_cmpli'
      INCLUDED_COLUMNS = %w[pdm_object_id
                            avail_for_dstrbn_ca_cd
                            ec_fulfil_rule_ca_cd
                            ec_fulfil_rule_ca_name
                            transfrbl_to_ca_ind].freeze
      default_scope { select(INCLUDED_COLUMNS) }

      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :compliance
    end
  end
end