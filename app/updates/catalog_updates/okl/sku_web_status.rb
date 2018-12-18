module CatalogUpdates
  module OKL
    class SkuWebStatus
      def arel
        CatModels::Sku
          .joins('join (select sku_id from concept_skus group by sku_id having count(*) = 1) cs using(sku_id)')
      end

      def execute_update(sku_ids)
        CatModels::Sku.connection.execute(update_statement(sku_ids.compact))
      end

      private

      def update_statement(sku_ids)
        <<~SQL
          update skus
          set web_status = cs.web_status
          from concept_skus cs
          where skus.sku_id = cs.sku_id
            and skus.sku_id in (#{sku_ids.join(',')})
        SQL
      end
    end
  end
end
