require 'rails_helper'

RSpec.describe Inbound::Messages::OKL::Product do
  let(:message_data) { { product_id: 123, name: 'first product' }.as_json }
  let(:message) { described_class.new(message_data) }

  it '#item_id returns product_id' do
    expect(message.item_id).to eq 123
  end

  it 'has one record' do
    expect(message.records.size).to be 1
  end

  context 'product attributes' do
    let(:product) { message.records.find { |r| r.is_a? Inbound::OKL::ProductRevision } }
    it('includes product Id') { expect(product.source_product_id).to eq 123 }
    it('includes name') { expect(product.name).to eq 'first product' }
  end

  context 'with unknown attributes' do
    let(:message_data) { { product_id: 123, name: 'with unknown attributes', go: 'bears' }.as_json }

    it '#to_active_record does not error' do
      expect { message.records }.not_to raise_error
    end
  end

  it 'after mapping, item_id still available' do
    message.records
    expect(message.item_id).to eq 123
  end
end
