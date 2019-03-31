module Index
  class BatchError < ApplicationRecord
    self.primary_key = :index_batch_error_id
    belongs_to :batch, class_name: 'Index::Batch', primary_key: :index_batch_id,
                       foreign_key: :index_batch_id, inverse_of: :batch_errors
    belongs_to :indexed_item, polymorphic: true
  end
end
