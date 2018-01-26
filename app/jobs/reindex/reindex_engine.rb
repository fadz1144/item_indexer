module Reindex
  class ReindexEngine
    attr_accessor :until_time

    def initialize(until_time, reindex_summary)
      @reindex_summary = reindex_summary
      @until_time = until_time
    end

    def run
      RedisSimpleMutex.run_with_lock(@reindex_summary.lock_name, 300) do |_mutex|
        reindex
      end
    end

    private

    def reindex
      Indexer::Audit.create!(index_type: index_type, important_datetime: until_time).execute_and_record_status! do
        sku_ids = @reindex_summary.changed_sku_ids(until_time)

        if sku_ids.present?
          reindex_skus(sku_ids)
          reindex_products(sku_ids)
        end
      end
    end

    def reindex_skus(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer).publish_to_search_by_ids(sku_ids)
    end

    def reindex_products(sku_ids)
      product_ids = Indexer::ProductIndexer.new.fetch_ids_for_sku_ids(sku_ids)
      Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer).publish_to_search_by_ids(product_ids)
    end

    def index_type
      @reindex_summary.index_type
    end
  end
end
