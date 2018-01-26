module Reindex
  class CategoryReindexJob < BaseReindexJob
    def changed_sku_ids(until_time)
      category_ids = changed_category_ids(until_time)
      sku_ids_for_category_ids(category_ids)
    end

    def index_type
      'category'
    end

    def start_time
      Indexer::Audit.last_successful_important_time('category') || Indexer::Audit.last_successful_important_time('sku')
    end

    private

    def changed_category_ids(until_time)
      CatModels::Category.where('updated_at > :start_time AND updated_at <= :end_time',
                                start_time: start_time, end_time: until_time).order(:category_id).distinct.ids
    end

    def sku_ids_for_category_ids(category_ids)
      CatModels::Sku.joins(:category).where(category_id: category_ids).order(:sku_id).distinct.ids
    end
  end
end
