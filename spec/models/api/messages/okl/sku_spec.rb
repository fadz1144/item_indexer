require 'rails_helper'

RSpec.describe API::Messages::OKL::Sku do
  let(:message_data) do
    { sku_id: 123,
      brand_id: 234,
      sku_shipping: {},
      sku_dimensions: {},
      sku_states: {},
      sku_attributes: {},
      images: [{}] }.as_json
  end
  let(:message) { described_class.new(message_data) }

  it '#item_id returns sku_id' do
    expect(message.item_id).to eq 123
  end

  context '#to_active_record' do
    let(:record) { message.to_active_record }
    it('includes sku Id') { expect(record.sku_id).to eq 123 }
    it('includes brand Id') { expect(record.brand_id).to eq 234 }
  end

  context '#children' do
    let(:classes) { message.children.map(&:class) }

    it 'includes shipping' do
      expect(classes).to include(API::Messages::OKL::SkuShipping)
    end

    it 'includes dimensions' do
      expect(classes).to include(API::Messages::OKL::SkuDimensions)
    end

    it 'includes state' do
      expect(classes).to include(API::Messages::OKL::SkuState)
    end

    it 'includes sku attributes' do
      expect(classes).to include(API::Messages::OKL::SkuAttribute)
    end

    it 'includes state' do
      expect(classes).to include(API::Messages::OKL::SkuImage)
    end
  end

  it 'sets sku_id on all records' do
    expect(message.records.all? { |r| r.sku_id == 123 }).to be_truthy
  end

  context 'with two sku attribute entries' do
    let(:message_data) do
      { sku_id: 123,
        sku_shipping: {},
        sku_dimensions: {},
        sku_states: {},
        sku_attributes: {},
        images: [{}, {}] }.as_json
    end

    it 'has two images' do
      images = message.children.select { |c| c.is_a? API::Messages::OKL::SkuImage }
      expect(images.size).to be 2
    end
  end
end
