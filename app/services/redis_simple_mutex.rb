# = Redis Simple Mutex
#
# The Redis Simple Mutex class is a non-blocking mutex. If the lock is not available, it returns false and does not
# try again to acquire the lock. The assumption is another process will try at a later time to acquire the lock.
class RedisSimpleMutex
  def self.redis
    @redis ||= Redis::Namespace.new(name,
                                    redis: RedisInitializer.redis(Rails.configuration.settings, 'mutex'))
  end

  def initialize(key, ttl = 120)
    @key = key
    @ttl = ttl
  end

  def redis
    self.class.redis
  end

  def lock
    if redis.setnx(@key, signature)
      expire
      true
    else
      false
    end
  end

  def extend
    raise "Cannot extend, lock not owned: #{@key}" unless owned?
    expire
  end

  def unlock
    owned? ? redis.del(@key) : raise("Cannot unlock, lock not owned: #{@key}")
  end

  def owned?
    redis.get(@key) == signature
  end

  def self.run_with_lock(lock_name, ttl = nil)
    raise 'Block missing' unless block_given?

    mutex = RedisSimpleMutex.new(lock_name, ttl)
    if mutex.lock
      yield
      true
    else
      Rails.logger.info "Failed to acquire lock for '#{lock_name}'"
      false
    end
  ensure
    mutex.unlock
  end

  private

  def signature
    object_id.to_s
  end

  def expire
    redis.expire(@key, @ttl)
  end
end
