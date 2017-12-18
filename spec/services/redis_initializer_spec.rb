require 'rails_helper'

RSpec.describe RedisInitializer do
  let(:redis) { described_class.new(settings, 'test_db') }

  context 'with no redis token' do
    let(:settings) { { non_redis_token: 'oski' } }

    it 'raises error' do
      expect { redis }.to raise_error RedisInitializer::NoRedisConfigurationFoundError
    end
  end

  context 'with no database token' do
    let(:settings) { { redis: { not_the_db_token: 'oski' } } }

    it 'raises error' do
      expect { redis }.to raise_error RedisInitializer::NoRedisConfigurationFoundError
    end
  end

  context 'with redis and database token' do
    let(:settings) do
      { 'redis' =>
        { 'test_db' =>
            { 'host' => 'redis_host',
              'port' => 123,
              'test_db' => 2 } } }
    end

    it 'does not raise error' do
      expect { redis }.not_to raise_error
    end

    it 'populates redis' do
      expect(redis.redis).to be_a Redis
    end

    it 'has connection options' do
      expect(redis.redis.client.options).to include(settings['redis']['test_db'])
    end

    it 'class method returns redis' do
      expect(described_class.redis(settings, 'test_db')).to be_a Redis
    end
  end
end
