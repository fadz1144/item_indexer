require 'rails_helper'

RSpec.describe BatchResizer do
  let(:call_tracker) { [] }
  let(:resizer) { described_class.new(3) { |batch| call_tracker.push(batch) } }

  context 'less entries than batch size' do
    before { resizer.push([1, 2]) }

    it 'does not call block during push' do
      expect(call_tracker).to be_empty
    end

    it 'calls block during flush' do
      resizer.flush
      expect(call_tracker).to contain_exactly([1, 2])
    end
  end

  context 'entries matching batch size' do
    before { resizer.push([1, 2, 3]) }

    it 'calls block once' do
      expect(call_tracker).to contain_exactly([1, 2, 3])
    end

    it 'does nothing during flush' do
      resizer.flush
      expect(call_tracker.size).to eq 1
    end
  end

  context 'more entries than batch size (but less than twice the size)' do
    before { resizer.push([1, 2, 3, 4]) }

    it 'calls block once' do
      expect(call_tracker).to contain_exactly([1, 2, 3])
    end

    it 'calls a second time during flush' do
      resizer.flush
      expect(call_tracker).to contain_exactly([1, 2, 3], [4])
    end
  end

  context 'more than double the batch size' do
    before { resizer.push([1, 2, 3, 4, 5, 6, 7]) }

    it 'class block twice' do
      expect(call_tracker).to contain_exactly([1, 2, 3], [4, 5, 6])
    end

    it 'picks up the extra during flush' do
      resizer.flush
      expect(call_tracker.size).to eq 3
    end
  end
end
