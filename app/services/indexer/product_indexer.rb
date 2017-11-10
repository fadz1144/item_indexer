module Indexer
  class ProductIndexer < BaseIndexer
    attr_accessor :logger

    def initialize(logger: Rails.logger)
      super(logger: logger)
    end

    def determine_count
      count = if ENV['PRODUCT_COUNT']
                ENV['PRODUCT_COUNT'].to_i
              else
                CatModels::Product.joins(:skus).order(:product_id).distinct.pluck(:product_id).count
              end
      logger.info "Total num products to index: #{count}"
      count
    end

    def index_type
      ENV['INDEX_TYPE'] || 'product'
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      pids = CatModels::Product.joins(:skus).order(:product_id).distinct.limit(limit).offset(offset).pluck(:product_id)
      pids.each_slice(chunk_size).with_index do |product_ids, i|
        handle_publish_chunk(chunk_size, i, limit, offset, product_ids)
      end
    end

    def id_for_item(item)
      item.product_id
    end

    def raw_json(item)
      ProductSerializer.new(item).as_json
    end

    def objects_by_ids(ids)
      # BARF
      CatModels::Product.includes(:brand, :category, skus: [:brand, :category, :products,
                                                            concept_skus: %i[concept_brand concept_vendor
                                                                             concept_sku_images concept_sku_pricing
                                                                             concept_sku_dimensions]])
                        .where(product_id: ids)
    end
  end
end
