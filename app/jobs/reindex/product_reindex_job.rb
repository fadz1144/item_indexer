module Reindex
  class ProductReindexJob < BaseReindexJob
    queue_as :reindex

    def changed_sku_ids(until_time)
      product_ids = changed_product_ids(until_time)
      sku_ids_for_product_ids(product_ids)
    end

    def index_type
      'product'
    end

    private

    def changed_product_ids(until_time)
      CatModels::Product.where('updated_at > :start_time AND updated_at <= :end_time',
                               start_time: start_time, end_time: until_time).order(:product_id).distinct.ids
    end

    def sku_ids_for_product_ids(product_ids)
      CatModels::Sku.joins(:product_memberships).where(product_id: product_ids).order(:sku_id).distinct.ids
    end

    def start_time
      Indexer::Audit.last_successful_important_time('product') || Indexer::Audit.last_successful_important_time('sku')
    end
  end
end
