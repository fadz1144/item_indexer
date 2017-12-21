module Transform
  class BatchError < ApplicationRecord
    self.primary_key = :transform_batch_error_id
    belongs_to :batch, class_name: 'Transform::Batch', primary_key: :transform_batch_id,
                       foreign_key: :transform_batch_id, inverse_of: :batch_errors
    belongs_to :source_item, polymorphic: true
  end
end
