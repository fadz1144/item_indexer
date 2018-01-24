module Reindex
  class SkuReindexJob < ApplicationJob
    queue_as :reindex

    def perform(until_time = DateTime.current)
      lock_name = "#{self.class.name}:#{until_time}"
      RedisSimpleMutex.run_with_lock(lock_name) do |_mutex|
        reindex(until_time)
      end
    end

    private

    def reindex(until_time)
      start_time = Indexer::Audit.last_successful_important_time('sku')
      sku_ids    = Indexer::SkuIndexer.new.fetch_ids_changed_in_range(start_time, until_time)
      Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).publish_to_search_by_ids(sku_ids)

      product_ids = Indexer::ProductIndexer.new.fetch_ids_for_sku_ids(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).publish_to_search_by_ids(product_ids)
    end
  end
end
