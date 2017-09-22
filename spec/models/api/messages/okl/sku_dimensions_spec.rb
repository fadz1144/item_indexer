require 'rails_helper'

RSpec.describe API::Messages::OKL::SkuDimensions do
  let(:message_data) do
    { sku_id: 123,
      item_width: 11,
      shipping_width: 22 }.as_json
  end
  let(:message) { described_class.new(message_data) }

  context '#to_active_record' do
    let(:record) { message.to_active_record }

    it 'returns a Sku Dimensions Revision instance' do
      expect(record).to be_an_instance_of(Inbound::OKL::SkuDimensionsRevision)
    end

    it 'sets item_width' do
      expect(record.item_width).to eq 11
    end

    it 'sets shipping_width' do
      expect(record.shipping_width).to eq 22
    end
  end
end
