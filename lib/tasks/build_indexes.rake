require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'

namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'build_product_search_index' => :environment do
    # fetch all the products
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE).to_i
    es_batch_size = ENV.fetch('ES_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_ES_BATCH_SIZE).to_i
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES).to_i

    publisher = Indexer::IndexPublisherFactory.publisher_for(type: :product, platform: :es)
    publisher.perform(db_fetch_size, es_batch_size, num_processes)
  end

  desc 'Apply index schema, adding any/all fields that are missing'
  task 'apply_solr_schema' => :environment do
    solr_base_url = ENV.fetch('SOLR_INTERNAL_ENDPOINT')
    SOLR::SolrSchemaService.new.apply_solr_schema(solr_base_url: solr_base_url)
  end

  desc 'Builds the product index for SOLR'
  task 'build_solr_product_search_index' => :environment do
    # fetch all the products
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE).to_i
    es_batch_size = ENV.fetch('ES_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_ES_BATCH_SIZE).to_i
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES).to_i

    publisher = Indexer::IndexPublisherFactory.publisher_for(type: :product, platform: :solr)
    publisher.perform(db_fetch_size, es_batch_size, num_processes)
  end

  desc 'Builds a partial product re-index for SOLR'
  task :partial_product_solr_reindex, [:product_count] => :environment do |_t, args|
    product_count = args[:product_count]
    Indexer::PartialIndexer.reindex(:product, :solr, product_count)
  end

  desc 'Builds the sku index for (Bridge) Catalog'
  task 'build_sku_search_index' => :environment do
    # fetch all the skus
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE).to_i
    es_batch_size = ENV.fetch('ES_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_ES_BATCH_SIZE).to_i
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES).to_i

    publisher = Indexer::IndexPublisherFactory.publisher_for(type: :sku, platform: :es)
    publisher.perform(db_fetch_size, es_batch_size, num_processes)
  end

  desc 'Builds a partial product re-index for (Bridge) Catalog'
  task :partial_product_reindex, [:product_count] => :environment do |_t, args|
    product_count = args[:product_count]
    Indexer::PartialIndexer.reindex_products(product_count)
  end

  desc 'Builds a partial sku re-index for (Bridge) Catalog'
  task :partial_sku_reindex, [:product_count] => :environment do |_t, args|
    product_count = args[:product_count]
    Indexer::PartialIndexer.reindex_skus(product_count)
  end
end
