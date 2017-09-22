require 'rails_helper'

RSpec.describe API::Messages::OKL::Product do
  let(:message_data) { { product_id: 123, name: 'first product' }.as_json }
  let(:message) { described_class.new(message_data) }

  it '#item_id returns product_id' do
    expect(message.item_id).to eq 123
  end

  it '#attributes' do
    expect(message.model_attributes).to eq message_data
  end

  context '#to_active_record' do
    let(:record) { message.to_active_record }
    it 'creates a product revision' do
      expect(record).to be_a_kind_of(Inbound::OKL::ProductRevision)
    end

    it 'populates product_id on instance' do
      expect(record.product_id).to eq 123
    end

    it 'populates name on instance' do
      expect(record.name).to eq 'first product'
    end
  end

  it 'records' do
    expect(message.records.size).to be 1
  end

  context 'with unknown attributes' do
    let(:message_data) { { product_id: 123, name: 'with unknown attributes', go: 'bears' }.as_json }

    it '#to_active_record does not error' do
      expect { message.to_active_record }.not_to raise_error
    end
  end
end
