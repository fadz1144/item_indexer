module Index
  class Batch < ApplicationRecord
    self.primary_key = :index_batch_id
    has_many :batch_errors, class_name: 'Index::BatchError', foreign_key: :index_batch_id, autosave: true,
                            inverse_of: :batch, dependent: :destroy

    include StringEnums
    string_enum status: %w[in\ progress complete error]
    include ExecutableBatch

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status=(value)
      super
      self.stop_datetime = Time.current if complete? || error?
    end

    def status_reason=(value)
      super(value.truncate(255))
    end

    def elapsed
      return nil if stop_datetime.blank? || start_datetime.blank?
      elapsed = stop_datetime - start_datetime
      elapsed_minutes = elapsed.div 60
      elapsed_seconds = (elapsed % 60).round
      "#{elapsed_minutes} min #{elapsed_seconds} sec"
    end
  end
end
