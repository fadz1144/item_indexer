module Inbound
  module OKL
    class SkuImageRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', inverse_of: :images, optional: true
    end
  end
end
