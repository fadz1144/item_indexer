require 'rails_helper'

RSpec.describe API::Inbound::DatabaseService do
  let(:record) do
    spy(Inbound::OKL::ProductRevision).tap do |pr|
      allow(pr).to receive(:transaction) { |&block| block.call }
    end
  end
  let(:service) { described_class.new }
  let(:first_item) { spy(API::Messages::OKL::Product, records: [record, record]) }
  let(:second_item) { spy(API::Messages::OKL::Product, records: [record]) }
  let(:message) do
    instance_double(API::Messages::OKL::Message, transactional_items: [first_item, second_item])
  end

  context '#write_message' do
    before { service.write_message(123, message) }

    it 'has no errors' do
      expect(service.errors).to be_empty
    end

    it 'calls save on items' do
      expect(record).to have_received(:save!).thrice
    end
  end

  context 'with errors' do
    let(:bad_record) do
      spy(Inbound::OKL::ProductRevision).tap do |pr|
        allow(pr).to receive(:transaction) { |&block| block.call }
        allow(pr).to receive(:save!).and_raise('test error')
      end
    end
    let(:third_item) do
      spy(API::Messages::OKL::Product, records: [bad_record], item_id: 123, class: Inbound::OKL::ProductRevision)
    end
    let(:message) do
      instance_double(API::Messages::OKL::Message, transactional_items: [first_item, second_item, third_item])
    end

    it 'rescues exceptions' do
      expect { service.write_message(123, message) }.not_to raise_error
    end

    it 'records error for item' do
      service.write_message(123, message)
      expect(service.errors).to eq(123 => 'test error')
    end
  end
end
