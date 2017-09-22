require 'rails_helper'

RSpec.describe API::Messages::OKL::SkuAttribute do
  let(:message_data) do
    { sku_id: 123,
      code: 'mascot',
      value: 'oski' }.as_json
  end
  let(:message) { described_class.new(message_data) }

  context '#to_active_record' do
    let(:record) { message.to_active_record }

    it 'returns a Sku Attribute Revision instance' do
      expect(record).to be_an_instance_of(Inbound::OKL::SkuAttributeRevision)
    end

    it 'sets code' do
      expect(record.code).to eq 'mascot'
    end

    it 'sets value' do
      expect(record.value).to eq 'oski'
    end
  end
end
