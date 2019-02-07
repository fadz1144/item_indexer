require 'rails_helper'

describe Indexer::ConceptCollectionCache do
  let(:subject) { described_class }
  let(:model_class) { CatModels::ConceptCollection }
  let(:store_class) { ActiveSupport::Cache::MemoryStore }

  before do
    # ensure uninitialized Rails.configuration for each test
    rails_config_options.delete(:indexer_concept_collection_cache)
  end

  def rails_config_options
    Rails::Railtie::Configuration.class_variable_get(:@@options)
  end

  context '#fetch' do
    context 'without precache' do
      it 'cache should be created and model queried at time of first fetch' do
        expect(store_class).to receive(:new).and_return(store_class.new).once
        expect(model_class).to receive(:where).and_return('foo').once
        subject.fetch(1, 2)
      end

      it 'cache should be re-used at time of second fetch for same key' do
        expect(store_class).to receive(:new).and_return(store_class.new).once
        expect(model_class).to receive(:where).and_return('foo').once
        subject.fetch(1, 2)
        subject.fetch(1, 2)
      end

      it 'should miss when cache cleared after previous fetch for same key' do
        expect(store_class).to receive(:new).and_return(store_class.new).once
        expect(model_class).to receive(:where).and_return('foo').twice
        subject.fetch(1, 2)
        subject.clear
        subject.fetch(1, 2)
      end
    end

    context 'with precache' do
      it 'cache should be reused and hit without query on first fetch for pre-cached key' do
        concept_collections = [
          model_class.new(concept_id: 1, collection_id: 2),
          model_class.new(concept_id: 3, source_collection_id: 4)
        ]
        expect(model_class).to receive(:all).and_return(concept_collections)
        expect(store_class).to receive(:new).and_return(store_class.new).once
        expect(model_class).not_to receive(:where)
        subject.build
        subject.fetch(1, 2)
      end
    end
  end
end
