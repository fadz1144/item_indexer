require 'rails_helper'

RSpec.describe Inbound::Messages::OKL::Sku do
  let(:message_data) do
    { sku_id: 123,
      brand_id: 234,
      created_by: 345,
      sku_shipping: {},
      sku_dimensions: { created_by: 456 },
      sku_states: {},
      sku_images: [{}] }.as_json
  end
  let(:message) { described_class.new(message_data) }

  it '#item_id returns sku_id' do
    expect(message.item_id).to eq 123
  end

  context 'sku' do
    let(:sku) { message.records.find { |r| r.is_a? Inbound::OKL::SkuRevision } }
    it('includes sku Id') { expect(sku.sku_id).to eq 123 }
    it('includes brand Id') { expect(sku.brand_id).to eq 234 }
    it('maps created_by to source_created_by') { expect(sku.source_created_by).to eq 345 }
  end

  it 'propagates sku_id on all records' do
    expect(message.records.all? { |r| r.sku_id == 123 }).to be_truthy
  end

  context 'with two sku images entries' do
    let(:message_data) do
      { sku_id: 123,
        sku_shipping: {},
        sku_dimensions: {},
        sku_states: {},
        sku_attributes: {},
        sku_images: [{}, {}] }.as_json
    end

    it 'has two images' do
      images = message.records.select { |r| r.is_a? Inbound::OKL::SkuImageRevision }
      expect(images.size).to eq 2
    end
  end

  it 'applies attribute mapping to associations' do
    dimensions = message.records.select { |r| r.is_a? Inbound::OKL::SkuDimensionsRevision }
    expect(dimensions.map(&:source_created_by).uniq).to contain_exactly(456)
  end
end
