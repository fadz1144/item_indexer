require 'rails_helper'

RSpec.describe API::Messages::OKL::SkuShipping do
  let(:message_data) do
    { sku_id: 123,
      white_glove: true,
      entryway: false }.as_json
  end
  let(:message) { described_class.new(message_data) }

  context '#to_active_record' do
    let(:record) { message.to_active_record }

    it 'returns a Sku Shipping Revision instance' do
      expect(record).to be_an_instance_of(Inbound::OKL::SkuShippingRevision)
    end

    it 'sets white_glove' do
      expect(record.white_glove).to be_truthy
    end

    it 'sets entryway' do
      expect(record.entryway).to be_falsey
    end
  end
end
