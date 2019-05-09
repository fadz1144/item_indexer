require 'rails_helper'

RSpec.describe Index::Batch, type: :model do
  let(:batch) { described_class.new }

  def now
    Time.now.getlocal('-08:00')
  end

  context '#elapsed' do
    it 'shows hours and minutes elapsed' do
      batch.stop_datetime = now
      batch.start_datetime = batch.stop_datetime - 1234
      expect(batch.elapsed).to eq '20 min 34 sec'
    end

    it 'returns nil when missing start time' do
      batch.stop_datetime = now
      expect(batch.elapsed).to be_nil
    end

    it 'returns nil when missing stop time' do
      batch.start_datetime = now
      expect(batch.elapsed).to be_nil
    end
  end
end
