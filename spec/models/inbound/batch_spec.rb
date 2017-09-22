require 'rails_helper'

RSpec.describe Inbound::Batch, type: :model do
  let(:batch) { described_class.new }

  context '#mark_error' do
    before { batch.mark_error('out of coffee') }

    it 'sets status' do
      expect(batch.status).to eq Inbound::Batch::STATUS_ERROR
    end

    it 'sets status reason' do
      expect(batch.status_reason).to eq 'out of coffee'
    end
  end

  it 'truncates status reason' do
    batch.status_reason = ('a' * 300)
    expect(batch.status_reason.length).to be 255
  end
end
