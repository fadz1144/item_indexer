require 'rails_helper'

RSpec.describe API::Messages::OKL::SkuImage do
  let(:message_data) do
    { sku_id: 123,
      resource_path: 'go',
      resource_name: 'bears' }.as_json
  end
  let(:message) { described_class.new(message_data) }

  context '#to_active_record' do
    let(:record) { message.to_active_record }

    it 'returns a Sku Image Revision instance' do
      expect(record).to be_an_instance_of(Inbound::OKL::SkuImageRevision)
    end

    it 'sets resource_path' do
      expect(record.resource_path).to eq 'go'
    end

    it 'sets resource_name' do
      expect(record.resource_name).to eq 'bears'
    end
  end
end
