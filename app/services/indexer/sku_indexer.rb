module Indexer
  class SkuIndexer
    def determine_count
      CatModels::Sku.count
    end

    def audit
      Indexer::Audit.create!(index_type: index_type, counter: determine_count, important_datetime: max_updated_at)
    end

    def index_type
      'sku'
    end

    def fetch_ids_relation
      CatModels::Sku.order(:sku_id).distinct
    end

    def fetch_ids_changed_in_range(start_time = min_start_time, end_time = DateTime.current)
      # TODO: may need to join other fields to get the full list of sku_ids
      CatModels::Sku.where('updated_at > :start_time AND updated_at <= :end_time',
                           start_time: start_time, end_time: end_time).order(:sku_id).distinct
    end

    def raw_json(item)
      SkuSerializer.new(item).as_json
    end

    def fetch_items(ids)
      skus = CatModels::Sku.includes(:brand, :category,
                                     products: %i[concept_products],
                                     concept_skus: %i[concept_brand concept_vendor
                                                      concept_sku_images concept_sku_pricing concept_sku_dimensions])
                           .where(sku_id: ids)
      apply_decorators(skus)
    end

    def apply_decorators(skus)
      skus.map do |s|
        s.concept_skus.each do |cs|
          cs.extend(CatModels::ConceptSkuDecorator)
        end
        s.extend(CatModels::SkuDecorator)
      end
    end

    def max_updated_at
      # TODO: this may need to look at brand/category/etc
      CatModels::Sku.maximum(:updated_at)
    end

    private

    def min_start_time
      CatModels::Sku.minimum(:updated_at)
    end
  end
end
