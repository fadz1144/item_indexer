module Inbound
  class Batch < ApplicationRecord
    include StringEnums
    string_enum status: %w[in\ progress complete error]

    self.primary_key = :inbound_batch_id
    belongs_to :transform_batch, class_name: 'Transform::Batch', optional: true, primary_key: :transform_batch_id,
                                 inverse_of: :inbound_batch

    scope :ready_for_transformation, -> { where(status: STATUS_COMPLETE, transform_batch_id: nil) }

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status=(value)
      super
      self.stop_datetime = DateTime.current if complete? || error?
    end

    def status_reason=(value)
      super(value.truncate(255))
    end
  end
end
