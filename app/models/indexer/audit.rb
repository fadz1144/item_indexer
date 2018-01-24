module Indexer
  class Audit < ApplicationRecord
    self.primary_key = :indexer_audit_id
    self.table_name = 'indexer_audits'

    include StringEnums
    string_enum status: %w[in\ progress complete error]

    scope :completed, -> { where(status: STATUS_COMPLETE) }

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

    def self.last_successful_important_time(index_type)
      Indexer::Audit.completed.where(index_type: index_type).maximum
    end
  end
end
