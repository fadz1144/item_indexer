require 'rails_helper'

RSpec.describe API::Inbound::V1::SkusController do
  let(:service) { spy(Inbound::InboundMessageService) }
  let(:response) { post :batch, params: { source: :okl } }

  it 'instantiates inbound message service with source and data type' do
    expect(Inbound::InboundMessageService).to receive(:new).with('okl', :sku).and_return(service)
    response
  end

  context 'with response' do
    let(:response_data) { Inbound::Response.build_response(123, 234, []) }
    before do
      allow(Inbound::InboundMessageService).to receive(:new).with('okl', :sku).and_return(service)
      allow(service).to receive(:consume_message).and_return(response_data)
    end

    it 'returns status 201' do
      expect(response.status).to eq 201
    end
  end
end
