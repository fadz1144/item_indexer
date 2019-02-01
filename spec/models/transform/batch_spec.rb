require 'rails_helper'

RSpec.describe Transform::Batch do
  let(:batch) { described_class.new }

  context '#execute_and_record_status!' do
    let(:work) { -> {} }
    before do
      allow(batch).to receive(:save!)
      batch.execute_and_record_status!(&work)
    end

    it 'populates start timestamp' do
      expect(batch.start_datetime).not_to be_nil
    end

    it 'populates stop timestamp' do
      expect(batch.stop_datetime).not_to be_nil
    end

    it 'start <= stop' do
      expect(batch.start_datetime).to be <= batch.stop_datetime
    end

    it 'marks batch complete' do
      expect(batch.status).to eq described_class::STATUS_COMPLETE
    end

    context 'when error occurs' do
      let(:work) { -> { raise StandardError, 'sad story' } }

      it 'marks batch in error' do
        expect(batch.status).to eq described_class::STATUS_ERROR
      end

      it 'includes error in status reason' do
        expect(batch.status_reason).to eq 'sad story'
      end

      it 'stores the error' do
        expect(batch.rescued_error.inspect).to eq '#<StandardError: sad story>'
      end
    end
  end
end
