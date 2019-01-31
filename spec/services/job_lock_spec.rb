require 'rails_helper'

RSpec.describe JobLock do
  let(:mutex) { instance_spy(RedisSimpleMutex) }
  let(:job) { described_class.new('oski') }
  before { allow(RedisSimpleMutex).to receive(:new).and_return(mutex) }

  it 'looks up job ttl in settings' do
    expect(Rails.configuration.settings).to receive(:dig).with('job_lock_ttl_in_seconds', 'oski')
    described_class.new('oski')
  end

  context 'ttl' do
    after { described_class.new('oski') }

    it 'uses configuration setting' do
      allow(Rails.configuration.settings)
        .to receive(:dig).with('job_lock_ttl_in_seconds', 'oski').and_return(42)
      expect(RedisSimpleMutex).to receive(:new).with('oski', 42)
    end
  end

  context 'lock available' do
    before { allow(mutex).to receive(:lock).and_return(true) }

    it('yields') { expect { |b| job.with_lock(&b) }.to yield_with_args(job) }

    it 'releases lock' do
      expect(mutex).to receive(:unlock)
      job.with_lock {}
    end
  end

  context 'lock not available' do
    before { allow(mutex).to receive(:lock).and_return(false) }

    it('does not yield') { expect { |b| job.with_lock(&b) }.not_to yield_control }

    it 'does not try to releases lock' do
      expect(mutex).not_to receive(:unlock)
      job.with_lock {}
    end
  end

  it 'delegates extend to mutex' do
    expect(mutex).to receive(:extend)
    job.extend
  end
end
