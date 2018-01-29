require 'rails_helper'

describe Reindex::SkuReindexJob do
  let(:job) { described_class.new }
  let(:sku_indexer) { double(Indexer::SkuIndexer) }
  let(:until_time) { DateTime.current }

  context '#changed_sku_ids' do
    before do
      allow(Indexer::SkuIndexer).to receive(:new).and_return(sku_indexer)
    end

    it 'should fetch changed ids' do
      expect(sku_indexer).to receive(:fetch_ids_changed_in_range).with(anything, until_time)

      job.changed_sku_ids(until_time)
    end
  end

  it 'should return an index type of sku' do
    expect(job.index_type == 'sku')
  end

  context '#start_time' do
    it 'should check the audit to retrieve the start time' do
      expect(Indexer::Audit).to receive(:last_successful_important_time)

      job.start_time
    end
  end
end
