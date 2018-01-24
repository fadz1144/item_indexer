module Indexer
  class ProductIndexer
    attr_accessor :logger

    def determine_count
      fetch_ids_relation.ids.count
    end

    def audit
      Indexer::Audit.create!(index_type: index_type, counter: determine_count, important_datetime: max_updated_at)
    end

    def index_type
      'product'
    end

    def fetch_ids_relation
      # CatModels::Product.joins(:skus).order(:product_id).distinct
      CatModels::Product.joins(:product_memberships).order(:product_id).distinct
    end

    def fetch_ids_for_sku_ids(sku_ids)
      CatModels::Product.joins(:product_memberships).where(sku_id: sku_ids).order(:product_id).distinct.ids
    end

    def raw_json(item)
      ProductSerializer.new(item).as_json
    end

    def fetch_items(ids)
      # BARF
      CatModels::Product.includes(:brand, :category, :concept_products,
                                  skus: [:brand, :category,
                                         products: %i[concept_products],
                                         concept_skus: %i[concept_brand concept_vendor
                                                          concept_sku_images concept_sku_pricing
                                                          concept_sku_dimensions]])
                        .where(product_id: ids)
    end

    def max_updated_at
      # TODO: this may need to look at sku/brand/category/etc
      CatModels::Product.maximum(:updated_at)
    end
  end
end
