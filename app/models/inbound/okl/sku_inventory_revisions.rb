module Inbound
  module OKL
    class SkuInventoryRevisions < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', inverse_of: :inventory, optional: true
    end
  end
end
