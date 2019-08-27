module External
  module XPDM
    class POSku < External::XPDM::Base
      self.table_name = 'ct_po_skus'
      self.primary_key = 'inumbr'

      INCLUDED_COLUMNS = %w[ponumb
                            inumbr
                            part_num
                            pomqty
                            pomorg].freeze

      default_scope -> { select(INCLUDED_COLUMNS) }

      belongs_to :sku, class_name: 'External::XPDM::Sku', foreign_key: :inumbr, inverse_of: :po_skus
      has_one :po_list, class_name: 'External::XPDM::POList', foreign_key: :ponumb, primary_key: :ponumb,
                        dependent: :destroy

      def self.source_includes
        [:po_list]
      end
    end
  end
end
