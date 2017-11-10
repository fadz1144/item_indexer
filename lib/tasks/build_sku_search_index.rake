require 'faraday_middleware/aws_signers_v4'
require 'active_model_serializers'
require 'thread'

desc 'Builds the sku index for (Bridge) Catalog'
task 'bridge:build_sku_search_index' => :environment do
  # fetch all the skus
  Indexer::SkuIndexer.new.perform
end
