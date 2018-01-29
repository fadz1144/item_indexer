module ExecutionWorkflow
  def execute_and_record_status!
    self.start_datetime = DateTime.current
    yield
    mark_complete
  rescue => e
    Rails.logger.error(([e.message] + e.backtrace).join("\n\t"))
    mark_error(e.message)
  ensure
    self.stop_datetime = DateTime.current
    verify_connection!
    save!
  end
  # rubocop:enable all

  private

  def verify_connection!
    self.class.connection.verify!
  end
end
