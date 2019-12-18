module External
  module XPDM
    class RelatedItem < External::XPDM::Base
      self.table_name = 'related_items'

      belongs_to :collection, class_name: 'External::XPDM::Collection', foreign_key: :sku
    end
  end
end
