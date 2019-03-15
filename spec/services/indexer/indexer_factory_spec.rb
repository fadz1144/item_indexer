require 'rails_helper'

describe Indexer::IndexerFactory do
  let(:subject) { described_class }

  context '#build_indexer' do
    it 'should build a product indexer' do
      expect(subject.build_indexer(factory_type: :product)).not_to be_nil
    end

    it 'should build a sku indexer' do
      expect(subject.build_indexer(factory_type: :sku)).not_to be_nil
    end

    it 'should raise an error for a bogus type' do
      expect { subject.build_indexer(factory_type: :bogus) }.to raise_error(NameError)
    end
  end
end
