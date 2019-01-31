class JobLock
  delegate :extend, to: :@mutex

  def initialize(lock_name)
    ttl = Rails.configuration.settings.dig('job_lock_ttl_in_seconds', lock_name)
    @mutex = RedisSimpleMutex.new(lock_name, ttl)
  end

  def with_lock
    lock_acquired = false

    if @mutex.lock
      lock_acquired = true
      yield self
    end
  ensure
    @mutex.unlock if lock_acquired
  end
end
