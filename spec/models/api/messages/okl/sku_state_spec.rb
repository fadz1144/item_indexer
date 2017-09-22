require 'rails_helper'

RSpec.describe API::Messages::OKL::SkuState do
  let(:message_data) do
    { sku_id: 123,
      copy_ready: true,
      content_ready: false }.as_json
  end
  let(:message) { described_class.new(message_data) }

  context '#to_active_record' do
    let(:record) { message.to_active_record }

    it 'returns a Sku State Revision instance' do
      expect(record).to be_an_instance_of(Inbound::OKL::SkuStateRevision)
    end

    it 'sets copy_ready' do
      expect(record.copy_ready).to be_truthy
    end

    it 'sets content_ready' do
      expect(record.content_ready).to be_falsey
    end
  end
end
