require 'rails_helper'

RSpec.describe Inbound::InboundMessageService do
  let(:message_data) { { message_id: 123, data: 'the data' }.stringify_keys }
  let(:database_service) { spy('database_service') }
  let(:flat_file_service) { spy('flat_file_service') }
  let(:transformation_job) { spy('transformation_job') }

  let(:service) do
    described_class.new('okl', 'sku').tap do |s|
      s.database_service = database_service
      s.flat_file_service = flat_file_service
      s.transformation_job = transformation_job
    end
  end
  let(:response) { service.consume_message(message_data) }

  context 'with invalid source' do
    before { service.instance_variable_set(:@source, 'bad_source') }

    it 'responds with error status' do
      expect(response.status).to eq 400
    end

    it 'does not create inbound batch' do
      expect(Inbound::Batch.count).to eq 0
    end
  end

  context '#consume_message' do
    before { response }
    it 'saves to database' do
      expect(database_service).to have_received(:write_message)
    end

    it 'saves to file' do
      expect(flat_file_service).to have_received(:write_to_file)
    end

    it 'creates batch' do
      expect(Inbound::Batch.count).to eq 1
    end

    it 'marks batch complete' do
      expect(Inbound::Batch.first.status).to eq Inbound::Batch::STATUS_COMPLETE
    end

    it 'enqueues transfer job' do
      expect(transformation_job).to have_received(:perform_later).with('okl')
    end
  end

  context 'with database service errors' do
    before { allow(database_service).to receive(:errors).and_return(123 => 'the error') }

    it 'responds with 207 status' do
      expect(response.status).to eq 207
    end

    it 'response includes errors' do
      expect(response.as_json.keys).to include(:errors)
    end

    it 'includes specific errors' do
      expect(response.as_json[:errors]).to match(123 => 'the error')
    end
  end

  it 'returns success response' do
    expect(response.status).to eq 201
  end

  it 'does not include an error message' do
    expect(response.as_json.fetch(:error_message, 'no error message present')).to eq 'no error message present'
  end

  it 'response includes status, code, message_id, and batch_id' do
    expect(response.as_json.keys).to include(:status, :code, :message_id, :batch_id)
  end

  it 'response includes message Id' do
    expect(response.as_json[:message_id]).to eq 123
  end

  it 'response includes batch Id' do
    expect(response.as_json[:batch_id]).to eq Inbound::Batch.first.inbound_batch_id
  end
end
