module Index
  class Batch < ApplicationRecord
    # honeybadger will be alerted when an indexing exceeds these thresholds
    ERROR_THRESHOLD = 100
    ELAPSED_SECONDS_THRESHOLD = 180 * 60

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

    def timing_complete?
      stop_datetime.present? && start_datetime.present?
    end

    def elapsed_seconds
      @elapsed_seconds ||= timing_complete? ? stop_datetime - start_datetime : nil
    end

    def elapsed
      return nil if stop_datetime.blank? || start_datetime.blank?
      elapsed = elapsed_seconds
      elapsed_minutes = elapsed.div 60
      elapsed_seconds = (elapsed % 60).round
      "#{elapsed_minutes} min #{elapsed_seconds} sec"
    end

    def postmortem
      Rails.logger.info 'starting postmortem...'
      warn_if_threshold('item errors', ERROR_THRESHOLD, error_count)
      warn_if_threshold('indexing duration (seconds)', ELAPSED_SECONDS_THRESHOLD, elapsed_seconds.round)
      Rails.logger.info 'starting postmortem...DONE'
    end

    private

    def warn_if_threshold(name, threshold, actual)
      warn "#{name} threshold of #{threshold} surpassed with #{actual}" if actual > threshold
    end

    def warn(text)
      batch_type = self.class.name
      description = "#{batch_type} warning: #{text}"
      context = { description: description, batch: attributes }
      Rails.logger.warn(description)
      Honeybadger.notify(description, tags: "#{batch_type}, batch, fail", context: context)
    end
  end
end
