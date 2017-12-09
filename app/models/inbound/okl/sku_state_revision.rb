module Inbound
  module OKL
    class SkuStateRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', inverse_of: :state, optional: true
    end
  end
end
