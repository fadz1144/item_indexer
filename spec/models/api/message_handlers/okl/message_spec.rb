require 'rails_helper'

RSpec.describe API::MessageHandlers::OKL::Message do
  let(:message_data) do
    { message_id: 123,
      data: [{ product_id: 1, name: 'first product' },
             { product_id: 2, name: 'second product' }] }.as_json
  end
  let(:message) { described_class.new(message_data, :product) }

  it '#data' do
    expect(message.data).to eq message_data
  end

  it '#message_id' do
    expect(message.message_id).to eq 123
  end

  context '#transactional_items' do
    it 'returns two items' do
      expect(message.transactional_items.size).to eq 2
    end

    it 'returns instances of product message' do
      expect(message.transactional_items.first.class).to be API::Messages::OKL::Product
    end
  end
end
