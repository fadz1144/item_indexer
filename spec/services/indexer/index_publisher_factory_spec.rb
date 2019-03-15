require 'rails_helper'

describe Indexer::IndexPublisherFactory do
  context '#publisher_for' do
    let(:subject) { described_class }
    it 'should return a publisher for :product' do
      expect(subject.publisher_for(type: :product)).not_to be_nil
    end

    it 'should return a publisher for :sku' do
      expect(subject.publisher_for(type: :sku)).not_to be_nil
    end
  end
end
