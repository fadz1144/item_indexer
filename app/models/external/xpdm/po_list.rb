module External
  module XPDM
    class POList < External::XPDM::Base
      self.table_name = 'ct_po_list'

      INCLUDED_COLUMNS = %w[ponumb
                            potype
                            postor
                            poedat2
                            posdat2
                            poretl
                            pounts
                            pocdat2].freeze

      default_scope -> { select(INCLUDED_COLUMNS) }

      belongs_to :po_sku, class_name: 'External::XPDM::POSku', foreign_key: :ponumb, primary_key: :ponumb
    end
  end
end
