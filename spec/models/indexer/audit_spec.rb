require 'rails_helper'

# TODO: How can we share behavior either from class or test or both with Transform::Batch
RSpec.describe Indexer::Audit do
  let(:audit) { described_class.new }

  context '#execute_and_record_status!' do
    let(:work) { -> {} }
    before do
      allow(audit).to receive(:save!)
      audit.execute_and_record_status!(&work)
    end

    it 'populates start timestamp' do
      expect(audit.start_datetime).not_to be_nil
    end

    it 'populates stop timestamp' do
      expect(audit.stop_datetime).not_to be_nil
    end

    it 'start <= stop' do
      expect(audit.start_datetime).to be <= audit.stop_datetime
    end

    it 'marks audit complete' do
      expect(audit.status).to eq described_class::STATUS_COMPLETE
    end

    context 'when error occurs' do
      let(:work) { -> { raise StandardError, 'sad story' } }

      it 'marks audit in error' do
        expect(audit.status).to eq described_class::STATUS_ERROR
      end

      it 'includes error in status reason' do
        expect(audit.status_reason).to eq 'sad story'
      end
    end
  end
end
