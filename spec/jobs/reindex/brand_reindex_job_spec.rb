require 'rails_helper'

describe Reindex::BrandReindexJob do
  let(:job) { described_class.new }
  let(:sku_indexer) { double(Indexer::SkuIndexer) }
  let(:until_time) { DateTime.current }

  let(:brand_audit_datetime) { '2018-01-15'.to_datetime }
  let(:sku_audit_datetime) { '2018-01-01'.to_datetime }

  context '#changed_sku_ids' do
    it 'should fetch changed ids' do
      expect { job.changed_sku_ids(until_time) }.not_to raise_exception
    end
  end

  it 'should return an index type of brand' do
    expect(job.index_type == 'brand')
  end

  context '#start_time' do
    before do
      allow(Indexer::Audit).to receive(:last_successful_important_time).with('brand')
                                                                       .and_return(brand_audit_datetime)
      allow(Indexer::Audit).to receive(:last_successful_important_time).with('sku')
                                                                       .and_return(sku_audit_datetime)
    end
    it 'should check the audit to retrieve the start time' do
      expect(job.start_time).to eq(brand_audit_datetime)
    end

    it 'should return sku_datetime if there is no brand audit time' do
      allow(Indexer::Audit).to receive(:last_successful_important_time).with('brand').and_return(nil)

      expect(job.start_time).to eq(sku_audit_datetime)
    end
  end
end
