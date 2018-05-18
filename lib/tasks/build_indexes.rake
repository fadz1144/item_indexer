require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'
# rubocop:disable Metrics/BlockLength
namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'build_product_search_index' => :environment do
    # fetch all the products
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE)
    es_batch_size = ENV.fetch('ES_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_ES_BATCH_SIZE)
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES)
    Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).perform(db_fetch_size,
                                                                              es_batch_size,
                                                                              num_processes)
  end

  desc 'Builds the sku index for (Bridge) Catalog'
  task 'build_sku_search_index' => :environment do
    # fetch all the skus
    db_fetch_size = ENV.fetch('DB_FETCH_SIZE', Indexer::IndexPublisher::DEFAULT_DB_FETCH_SIZE)
    es_batch_size = ENV.fetch('ES_BATCH_SIZE', Indexer::IndexPublisher::DEFAULT_ES_BATCH_SIZE)
    num_processes = ENV.fetch('NUM_PROCESSES', Indexer::IndexPublisher::DEFAULT_NUM_PROCESSES)
    Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).perform(db_fetch_size,
                                                                          es_batch_size,
                                                                          num_processes)
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
# rubocop:enable Metrics/BlockLength
