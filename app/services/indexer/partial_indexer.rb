module Indexer
  class PartialIndexer
    def self.reindex_products(product_count)
      product_ids = product_ids(product_count)
      publisher = Indexer::IndexPublisher.new(index_class: Indexer::ProductIndexer)
      publisher.publish_to_search_by_ids(product_ids)
    end

    def self.reindex_skus(product_count)
      publisher = Indexer::IndexPublisher.new(index_class: Indexer::SkuIndexer)
      sku_ids = sku_ids(product_count)
      publisher.publish_to_search_by_ids(sku_ids)
    end

    def self.sku_ids(product_count)
      product_ids = product_ids(product_count)
      sku_indexer = Indexer::SkuIndexer.new
      sku_indexer.fetch_sku_ids_for_product_ids(product_ids).pluck(:sku_id)
    end

    def self.product_ids(product_count)
      product_indexer = Indexer::ProductIndexer.new
      ids_relation = product_indexer.fetch_ids_relation.limit(product_count)
      ids_relation.pluck(:product_id)
    end
  end
end
