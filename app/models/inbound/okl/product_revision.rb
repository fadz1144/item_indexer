module Inbound
  module OKL
    class ProductRevision < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      include Inbound::CommonConceptForeignKeys
    end
  end
end
