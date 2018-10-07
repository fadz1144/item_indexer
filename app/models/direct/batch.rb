module Direct
  class Batch < ApplicationRecord
    self.primary_key = :direct_batch_id
    belongs_to :transform_batch, class_name: 'Transform::Batch', primary_key: :transform_batch_id,
                                 inverse_of: :direct_batch
    scope :most_recent, -> { order(direct_batch_id: :desc) }
    scope :incremental, -> { where(criteria_type: :incremental) }

    delegate :start_datetime, to: :transform_batch
  end
end
