module BackgroundTaskManager
  def run_in_background
    supervise_pid(fork { yield })
  end

  def wait_for_background_tasks
    Rails.logger.info 'Waiting for subprocesses to complete...'
    until child_processes.empty?
      child_processes.each { |pid| child_processes.delete(pid) unless running?(pid) }
      sleep 1
    end
  end

  # Rescue SignalException in your main process, and call this method -
  # it terminates all your background tasks, otherwise they run forever.
  def cleanup_on_terminate
    child_processes.each { |pid| Process.kill('TERM', pid) if running?(pid) }
  end

  protected

  def child_processes
    @child_processes ||= Set.new
  end

  def add_child(pid)
    child_processes.add pid
  end

  def supervise_pid(pid)
    add_child(pid)
    Process.detach(pid)
  end

  def running?(pid)
    Process.kill(0, pid) # Don't worry, kill 0 just checks to see if a process exists. Sends no signal :)
    true
  rescue
    false
  end
end
