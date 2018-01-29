module Indexer
  class Audit < ApplicationRecord
    include ExecutionWorkflow

    include StringEnums
    string_enum status: %w[in\ progress complete error]

    self.primary_key = :indexer_audit_id
    self.table_name = 'indexer_audits'

    scope :completed, -> { where(status: STATUS_COMPLETE) }

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status_reason=(value)
      super(value.truncate(255))
    end

    DEFAULT_DATE_TIME = '1970-01-01'.to_datetime
    def self.last_successful_important_time(index_type, use_default_datetime: true)
      last_important_time = Indexer::Audit.completed.where(index_type: index_type).maximum(:important_datetime)
      last_important_time = DEFAULT_DATE_TIME if last_important_time.nil? && use_default_datetime
      last_important_time
    end
  end
end
