module Reindex
  class BaseReindexJob < ApplicationJob
    def perform(until_time = DateTime.current)
      RedisSimpleMutex.run_with_lock(lock_name, 300) do |_mutex|
        reindex(until_time)
      end
    end

    def reindex(until_time)
      Indexer::Audit.create!(index_type: index_type, important_datetime: until_time).execute_and_record_status! do
        sku_ids = changed_sku_ids(until_time)

        if sku_ids.present?
          reindex_skus(sku_ids)
          reindex_products(sku_ids)
        end
      end
    end

    private
    
    def lock_name
      "#{self.class.name}:#{index_type}"
    end

    def changed_sku_ids(_until_time)
      raise 'Not implemented'
    end

    def index_type
      raise 'Not implemented'
    end

    def reindex_skus(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).publish_to_search_by_ids(sku_ids)
    end

    def reindex_products(sku_ids)
      product_ids = Indexer::ProductIndexer.new.fetch_ids_for_sku_ids(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).publish_to_search_by_ids(product_ids)
    end
  end
end
