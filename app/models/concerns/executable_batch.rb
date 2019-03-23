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
    mark_error(e.message)
    notify(e)
  ensure
    self.stop_datetime = Time.current
    save!
  end

  private

  def notify(exception)
    batch_type = self.class.name
    description = "#{batch_type} did not complete successfully"
    context = { description: description, batch: attributes }
    Rails.logger.error(description)
    Rails.logger.error(([exception.class.name, exception.message] + exception.backtrace).join("\n\t"))
    Honeybadger.notify(exception, tags: "#{batch_type}, batch, fail", context: context)
  end
end
