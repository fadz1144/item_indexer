module Indexer
  class PartialIndexer
    def self.reindex(type, platform, product_count)
      ids = ids(type: type, product_count: product_count)
      publisher = Indexer::IndexPublisherFactory.publisher_for(type: type, platform: platform)
      publisher.publish_to_search_by_ids(ids)
    end

    def self.reindex_products(product_count)
      reindex(:product, :es, product_count)
    end

    def self.reindex_skus(product_count)
      reindex(:sku, :es, product_count)
    end

    def self.product_ids(product_count)
      product_indexer = Indexer::ProductIndexer.new
      ids_relation = product_indexer.fetch_ids_relation.limit(product_count)
      ids_relation.pluck(:product_id)
    end

    def self.ids(type:, product_count:)
      pids = product_ids(product_count)
      if type == :product
        pids
      else
        Indexer::SkuIndexer.new.fetch_sku_ids_for_product_ids(pids).pluck(:sku_id)
      end
    end
  end
end
