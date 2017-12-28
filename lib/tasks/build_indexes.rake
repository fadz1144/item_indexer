require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'
require 'thread'

namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'build_product_search_index' => :environment do
    # fetch all the products
    Indexer::IndexPublisher.new.perform(index_class: Indexer::ProductIndexer)
  end

  desc 'Builds the sku index for (Bridge) Catalog'
  task 'build_sku_search_index' => :environment do
    # fetch all the skus
    Indexer::IndexPublisher.new.perform(index_class: Indexer::SkuIndexer)
  end
end
