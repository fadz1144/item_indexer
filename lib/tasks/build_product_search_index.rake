require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'
require 'thread'
# require_relative '../../app/services/indexer/product_indexer'

desc 'Builds the product index for (Bridge) Catalog'
task 'bridge:build_product_search_index' => :environment do
  # fetch all the products
  Indexer::ProductIndexer.new.perform
end
