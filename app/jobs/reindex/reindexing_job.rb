module Reindex
  class ReindexingJob < ApplicationJob
    queue_as :reindex

    def perform(until_time = DateTime.current)
      lock_name = "#{self.class.name}:#{until_time}"

      mutex = RedisSimpleMutex.new(lock_name)
      if mutex.lock
        run_service(until_time)
      else
        Rails.logger.info "Failed to acquire lock for '#{lock_name}'"
      end
    ensure
      mutex.unlock
    end

    private

    def run_service(until_time)
      start_time = Indexer::Audit.last_successful_important_time('sku')
      sku_ids = Indexer::SkuIndexer.new.fetch_ids_changed_in_range(start_time, until_time)
      Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).publish_to_search_by_ids(sku_ids)

      product_ids = Indexer::ProductIndexer.new.fetch_ids_for_sku_ids(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).publish_to_search_by_ids(product_ids)
    end
  end
end
