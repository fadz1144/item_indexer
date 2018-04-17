require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'
require 'thread'

namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'build_product_search_index' => :environment do
    # fetch all the products
    Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).perform
  end

  desc 'Builds the sku index for (Bridge) Catalog'
  task 'build_sku_search_index' => :environment do
    # fetch all the skus
    Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).perform
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
