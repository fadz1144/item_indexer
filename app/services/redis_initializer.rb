class RedisInitializer
  class NoRedisConfigurationFoundError < StandardError
    def initialize(token)
      super "No configuration found for redis #{token}; expected settings.yml to include keys ['redis']['#{token}']"
    end
  end

  attr_reader :redis
  REDIS_TOKEN = 'redis'.freeze

  def self.redis(settings, database_name)
    new(settings, database_name).redis
  end

  def initialize(settings, database_name)
    config = settings.fetch(REDIS_TOKEN, nil)&.fetch(database_name, nil)
    raise(NoRedisConfigurationFoundError, database_name) if config.nil?

    @redis = Redis.new(config)
    Rails.logger.debug "RedisInitializer for #{database_name}: #{@redis.inspect}"
  end
end
