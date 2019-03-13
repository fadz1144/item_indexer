module Indexer
  class SalesIndexer
    attr_accessor :logger

    def initialize(serializer_class: SOLR::SalesSerializer)
      @serializer_class = serializer_class
    end

    def determine_count
      fetch_ids_relation.ids.count
    end

    def index_type
      'sales'
    end

    def fetch_ids_relation
      CatModels::SkuSalesSummary
    end

    def raw_json(item)
      @serializer_class.new(item).as_json
    end

    def fetch_items(ids)
      CatModels::SkuSalesSummary.where(sku_sales_summary_id: ids)
    end
  end
end
