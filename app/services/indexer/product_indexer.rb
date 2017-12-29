module Indexer
  class ProductIndexer
    attr_accessor :logger

    def determine_count
      fetch_ids_relation.ids.count
    end

    def index_type
      'product'
    end

    def fetch_ids_relation
      # CatModels::Product.joins(:skus).order(:product_id).distinct
      CatModels::Product.joins(:product_memberships).order(:product_id).distinct
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
  end
end
