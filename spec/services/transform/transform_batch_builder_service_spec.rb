require 'rails_helper'

RSpec.describe Transform::TransformBatchBuilderService do
  let(:service) { described_class.new }
  let(:inbound_batch_id) { Inbound::Batch.create(inbound_attributes).id }
  let(:batch) { service.create_transform_batch_for_inbound_batch(inbound_batch_id) }

  shared_examples 'persisted batch with error' do |error_message|
    it 'creates batch' do
      expect(batch.persisted?).to be_truthy
    end

    it 'batch status is error' do
      expect(batch.error?).to be_truthy
    end

    it 'records status message' do
      expect(batch.status_reason).to match error_message
    end
  end

  context 'when inbound batch does not exist' do
    let(:inbound_batch_id) { 999 }
    it_behaves_like 'persisted batch with error', /Couldn't find Inbound::Batch with 'inbound_batch_id'=999/
  end

  context 'when inbound batch not complete' do
    let(:inbound_attributes) { { source: 'okl', data_type: 'sku', status: 'error' } }
    it_behaves_like 'persisted batch with error', /Inbound batch \d+ status is 'error'; must be complete/
  end

  context 'when inbound batch already assigned transformation' do
    let(:inbound_attributes) do
      { source: 'okl', data_type: 'sku', status: 'complete', transform_batch: Transform::Batch.create }
    end
    it_behaves_like 'persisted batch with error', /Inbound batch \d+ has already been assigned transformation \d+/
  end

  context 'happy path' do
    let(:inbound_attributes) { { source: 'okl', data_type: 'sku', status: 'complete' } }

    it 'creates batch' do
      expect(batch.persisted?).to be_truthy
    end

    it 'creates a transform batch instance' do
      expect(batch).to be_a Transform::Batch
    end

    it 'sets status to in progress' do
      expect(batch.in_progress?).to be_truthy
    end

    it 'populates inbound batch association on batch' do
      expect(batch.association(:inbound_batch).loaded?).to be_truthy
    end
  end
end
