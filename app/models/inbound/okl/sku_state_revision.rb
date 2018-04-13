module Inbound
  module OKL
    class SkuStateRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', inverse_of: :state, optional: true,
                       foreign_key: :inbound_okl_sku_revision_id
    end
  end
end
