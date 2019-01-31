require 'rails_helper'

RSpec.describe RedisSimpleMutex do
  let(:redis) { instance_spy(Redis) }
  let(:mutex) { described_class.new('oski', 123) }
  before { allow(described_class).to receive(:redis).and_return(redis) }

  context 'when lock available' do
    before { allow(redis).to receive(:setnx).and_return(true) }
    let(:lock_result) { mutex.lock }
    after { lock_result }

    it('logs') { expect(Rails.logger).to receive(:debug).with("Lock acquired for 'oski'") }
    it('sets ttl') { expect(redis).to receive(:expire).with('oski', 123) }
    it('returns true') { expect(lock_result).to be true }
  end

  context 'when lock not available' do
    before { allow(redis).to receive(:setnx).and_return(false) }
    let(:lock_result) { mutex.lock }
    after { lock_result }

    it('logs') { expect(Rails.logger).to receive(:info).with("Unable to acquire lock for 'oski'") }
    it('sets ttl') { expect(redis).not_to receive(:expire) }
    it('returns true') { expect(lock_result).to be false }
  end

  describe '#extend' do
    it 'delegates expire when owned' do
      allow(mutex).to receive(:owned?).and_return(true)
      expect(redis).to receive(:expire).with('oski', 123)
      mutex.extend
    end

    it 'raises exception when not owned' do
      expect { mutex.extend }.to raise_error('Cannot extend, lock not owned: oski')
    end
  end

  describe '#unlock' do
    after { mutex.unlock }
    it 'deletes key when owned' do
      allow(mutex).to receive(:owned?).and_return(true)
      expect(redis).to receive(:del).with('oski')
    end

    it 'warns when not owned' do
      expect(Rails.logger).to receive(:warn).with('Cannot unlock, lock not owned: oski')
    end
  end

  describe '#owned?' do
    it 'true when key matches signature' do
      allow(redis).to receive(:get).with('oski').and_return(mutex.object_id.to_s)
      expect(mutex.owned?).to be true
    end

    it 'false when key does not match signature' do
      allow(redis).to receive(:get).with('oski').and_return('another signature')
      expect(mutex.owned?).to be false
    end
  end
end
