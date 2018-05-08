module Inbound
  module OKL
    class SkuDimensionsRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      belongs_to :sku, class_name: 'Inbound::OKL::SkuRevision', inverse_of: :dimensions, optional: true,
                       foreign_key: :inbound_okl_sku_revision_id
    end
  end
end
