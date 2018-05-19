require 'rails_helper'

describe Indexer::IndexerFactory do
  let(:subject) { described_class }

  context '#build_indexer' do
    it 'should allow us to call with :solr' do
      expect(subject.build_indexer(factory_type: :product, platform: :solr)).not_to be_nil
    end

    it 'should allow us to call with :es' do
      expect(subject.build_indexer(factory_type: :product, platform: :es)).not_to be_nil
    end

    it 'should raise an error with an unknown platform' do
      expect { subject.build_indexer(factory_type: :product, platform: :bogus) }.to raise_error(ArgumentError)
    end

    it 'should build a sku indexer for es' do
      expect(subject.build_indexer(factory_type: :sku, platform: :es)).not_to be_nil
    end

    it 'should raise an error for a bogus type' do
      expect { subject.build_indexer(factory_type: :bogus, platform: :es) }.to raise_error(NameError)
    end
  end
end
