#= Executable Batch
#
# Module Executable Batch provides a block that records start and stop time as well as marking the batch complete or
# rescuing any errors. If an error is rescued, it is available via attribute :rescued_error.
module ExecutableBatch
  extend ActiveSupport::Concern
  included do
    attr_reader :rescued_error
  end

  def execute_and_record_status!
    self.start_datetime = Time.current
    yield
    mark_complete
  rescue => e
    @rescued_error = e
    Rails.logger.error(([e.message] + e.backtrace).join("\n\t"))
    mark_error(e.message)
  ensure
    self.stop_datetime = Time.current
    save!
  end
end
