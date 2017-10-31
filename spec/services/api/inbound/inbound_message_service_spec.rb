require 'rails_helper'

RSpec.describe API::Inbound::InboundMessageService do
  let(:message) do
    instance_double(API::MessageHandlers::OKL::Message,
                    message_id: 123, source: :okl, data_type: :product, data: 'the data')
  end
  let(:database_service) { spy('database_service') }
  let(:flat_file_service) { spy('flat_file_service') }
  let(:service) do
    described_class.new.tap do |s|
      s.database_service = database_service
      s.flat_file_service = flat_file_service
    end
  end

  it 'creates inbound batch entry' do
    expect(Inbound::Batch).to receive(:create!)
    service.consume_message(message)
  end

  context '#consume_message' do
    before do
      allow(Inbound::Batch).to receive(:create!).and_return(
        instance_double(Inbound::Batch, inbound_batch_id: 234, save: true)
      )
      service.consume_message(message)
    end

    it 'saves to database' do
      expect(database_service).to have_received(:write_message).with(234, message)
    end

    it 'saves to file' do
      expect(flat_file_service).to have_received(:write_to_file).with(name: 'okl_product_234', data: message.data)
    end
  end

  it 'returns response object' do
    expect(service.consume_message(message)).to be_a_kind_of(API::Response)
  end
end
