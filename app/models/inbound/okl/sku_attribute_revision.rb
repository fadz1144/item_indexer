module Inbound
  module OKL
    class SkuAttributeRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', optional: true
    end
  end
end
