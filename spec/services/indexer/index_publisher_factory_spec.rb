require 'rails_helper'

describe Indexer::IndexPublisherFactory do
  context '#publisher_for' do
    let(:subject) { described_class }
    it 'should return a publisher for :es, :product' do
      expect(subject.publisher_for(type: :product, platform: :es)).not_to be_nil
    end

    it 'should return a publisher for :es, :sku' do
      expect(subject.publisher_for(type: :sku, platform: :es)).not_to be_nil
    end

    it 'should return a publisher for :solr, :product' do
      expect(subject.publisher_for(type: :product, platform: :solr)).not_to be_nil
    end

    xit 'should return a publisher for :solr, :sku' do
      expect(subject.publisher_for(type: :sku, platform: :solr)).not_to be_nil
    end
  end
end
