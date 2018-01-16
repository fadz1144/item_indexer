module Inbound
  module OKL
    class BrandRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
    end
  end
end
