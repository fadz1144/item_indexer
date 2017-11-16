module Indexer
  class SkuIndexer < BaseIndexer
    def initialize(logger: Rails.logger)
      super(logger: logger)
    end

    def determine_count
      count = if ENV['SKU_COUNT']
                ENV['SKU_COUNT'].to_i
              else
                CatModels::Sku.count
              end
      logger.info "Total num skus to index: #{count}"
      count
    end

    def index_type
      ENV['INDEX_TYPE'] || 'sku'
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      ids = CatModels::Sku.order(:sku_id).distinct.limit(limit).offset(offset).pluck(:sku_id)
      ids.each_slice(chunk_size).with_index do |sku_ids, i|
        handle_publish_chunk(chunk_size, i, limit, offset, sku_ids)
      end
    end

    def id_for_item(item)
      item.sku_id
    end

    def raw_json(item)
      SkuSerializer.new(item).as_json
    end

    def objects_by_ids(ids)
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
