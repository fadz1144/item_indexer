module Reindex
  class BrandReindexJob < BaseReindexJob
    def changed_sku_ids(until_time)
      brand_ids = changed_brand_ids(until_time)
      sku_ids_for_brand_ids(brand_ids)
    end

    def index_type
      'brand'
    end

    private

    def start_time
      Indexer::Audit.last_successful_important_time('brand') || Indexer::Audit.last_successful_important_time('sku')
    end

    def changed_brand_ids(until_time)
      CatModels::Brand.where('updated_at > :start_time AND updated_at <= :end_time',
                             start_time: start_time, end_time: until_time).order(:brand_id).distinct.ids
    end

    def sku_ids_for_brand_ids(brand_ids)
      CatModels::Sku.joins(:brand).where(brand_id: brand_ids).order(:sku_id).distinct.ids
    end
  end
end
