module Transform
  class Batch < ApplicationRecord
    self.primary_key = :transform_batch_id
    has_one :inbound_batch, class_name: 'Inbound::Batch', foreign_key: :transform_batch_id,
                            primary_key: :transform_batch_id, inverse_of: :transform_batch
    has_many :batch_errors, class_name: 'Transform::BatchError', foreign_key: :transform_batch_id, autosave: true,
                            inverse_of: :batch

    include StringEnums
    string_enum status: %w[in\ progress complete error]

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status_reason=(value)
      super(value.truncate(255))
    end

    def execute_and_record_status!
      self.start_datetime = DateTime.current
      yield
      mark_complete
    rescue => e
      Rails.logger.error(([e.message] + e.backtrace).join("\n\t"))
      mark_error(e.message)
    ensure
      self.stop_datetime = DateTime.current
      save!
    end
  end
end
