module Reindex
  class SkuReindexJob < BaseReindexJob
    queue_as :reindex

    def changed_sku_ids(until_time)
      Indexer::SkuIndexer.new.fetch_ids_changed_in_range(start_time, until_time)
    end

    def index_type
      'sku'
    end

    private

    def start_time
      Indexer::Audit.last_successful_important_time('sku')
    end
  end
end
