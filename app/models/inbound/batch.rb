module Inbound
  class Batch < ApplicationRecord
    self.primary_key = :inbound_batch_id
    include StringEnums
    string_enum status: %w[in\ progress complete error]

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status_reason=(value)
      super(value.truncate(255))
    end
  end
end
