module External
  module ECOM
    class InventoryLoader
      CONCEPT_IDS_WITH_INVENTORY = [1, 2, 4].freeze
      def base_arel
        External::ECOM::Inventory
      end

      def transformer_class
        Transform::Transformers::ECOM::Inventory
      end

      # this is opposite of the engine's transform_items method; because a single source has multiple targets, this
      # indexes the source records then loops through the targets; each target is an array of concept skus
      def transform(_engine, arel)
        arel.in_batches do |batch|
          indexed_sources = batch.index_by(&:sku)
          target_skus(indexed_sources.keys) do |sku_id, concept_skus|
            source = indexed_sources[sku_id]
            concept_skus.each { |cs| update_concept_sku(source, cs) }
          end
        end

        move_inventory_based_on_vdc_sku
      end

      private

      def target_skus(sku_ids)
        target_skus_arel(sku_ids).in_batches do |batch|
          batch.group_by(&:sku_id).each_pair { |sku_id, concept_skus| yield sku_id, concept_skus }
        end
      end

      def target_skus_arel(sku_ids)
        CatModels::ConceptSku
          .where(sku_id: sku_ids, concept_id: CONCEPT_IDS_WITH_INVENTORY)
          .joins(:sku)
          .where.not(canadian_sku_not_sellable_there)
      end

      def canadian_sku_not_sellable_there
        <<~SQL
              concept_skus.concept_id = 2
          and skus.available_in_ca_dist_cd is null
          and skus.ca_fulfillment_cd not in ('E', 'R')
          and skus.transferable_to_canada = false
        SQL
      end

      def update_concept_sku(source, concept_sku)
        transformer = transformer_class.new(source)
        concept_sku.update_columns( # rubocop:disable Rails/SkipsModelValidations
          transformer.qty_attribute_values(concept_sku.concept_id).merge(updated_at: Time.current)
        )
      end

      def move_inventory_based_on_vdc_sku
        [move_warehouse_to_vdc_sql, move_vdc_to_warehouse_sql].each do |sql|
          CatModels::ConceptSku.connection.execute(sql)
        end
      end

      def move_warehouse_to_vdc_sql
        <<~SQL
          update concept_skus
          set vdc_avail_qty = warehouse_avail_qty, warehouse_avail_qty = 0
          from skus s
          where s.sku_id = concept_skus.sku_id
            and concept_id <> 3
            and warehouse_avail_qty > 0
            and s.vdc_sku = true
        SQL
      end

      def move_vdc_to_warehouse_sql
        <<~SQL
          update concept_skus
          set warehouse_avail_qty = vdc_avail_qty, vdc_avail_qty = 0
          from skus s
          where s.sku_id = concept_skus.sku_id
            and concept_id <> 3
            and vdc_avail_qty > 0
            and s.vdc_sku = false
        SQL
      end
    end
  end
end
