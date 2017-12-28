module Indexer
  class SkuIndexer
    def determine_count
      CatModels::Sku.count
    end

    def index_type
      'sku'
    end

    def fetch_ids_relation
      CatModels::Sku.order(:sku_id).distinct
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
  end
end
