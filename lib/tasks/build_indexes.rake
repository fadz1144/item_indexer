require 'active_model_serializers'

namespace :bridge do
  desc 'Apply index schema, adding any/all fields that are missing'
  task 'apply_solr_schema' => :environment do
    solr_base_url = ENV.fetch('SOLR_INTERNAL_ENDPOINT')
    SOLR::SolrSchemaService.new.apply_solr_schema(solr_base_url: solr_base_url)
  end

  desc 'Pings SOLR index to verify successful connection'
  task 'ping_solr' => :environment do
    SOLR::SOLRClient.new.ping
  end

  desc 'Builds the product index for Universal Product Catalog'
  task 'build_solr_product_search_index' => :environment do
    # fetch all the products
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE).to_i
    index_batch_size = ENV.fetch('INDEX_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_INDEX_BATCH_SIZE).to_i
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES).to_i

    publisher = Indexer::IndexPublisherFactory.publisher_for(type: :product)
    publisher.perform(db_fetch_size, index_batch_size, num_processes)
  end

  desc 'Builds a partial product re-index for Universal Product Catalog'
  task :partial_product_solr_reindex, [:product_count] => :environment do |_t, args|
    product_count = args[:product_count]
    Indexer::PartialIndexer.reindex(:product, product_count)
  end
end
