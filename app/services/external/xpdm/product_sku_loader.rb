module External
  module XPDM
    # Product Sku Loader
    #
    # The Product Sku Loader class loads skus based on the products that are already loaded. It first selects from the
    # concept_products table to get pdm_object_id's for the loaded products (in batches of 1,000). It takes those and
    # fetches the pdm_object_id's for the products' skus from the product membership table in XPDM (pdm_item_rltn).
    # Finally, it takes the sku Ids (1,000 at a time) to the main sku table in XPDM (pdm_item_prod_info).
    #
    # The count that is logged is a count of products, not the resulting skus.
    class ProductSkuLoader
      def initialize(include_inventory = false)
        @include_inventory = include_inventory
      end

      def base_arel
        # there are three concept skus per product, restricting to BBBY makes it 1-to-1 with product
        CatModels::ConceptProduct.where(concept_id: 1)
      end

      def transformer_class
        Transform::Transformers::XPDM::Sku
      end

      def transform(engine, arel)
        includes = Transform::Transformers::XPDM::Sku.source_includes
        includes << :inventory if @include_inventory

        # sku_ids_in_batches returns the skus for 1,000 products; resize to transform 1,000 skus at a time
        batch_resizer = BatchResizer.new(1_000) { |ids| transform_batch(engine, includes, ids) }

        sku_ids_in_batches(arel) { |pdm_object_ids| batch_resizer.push(pdm_object_ids) }
        batch_resizer.flush
      end

      def restart_id
        External::XPDM::ProductMembershipLocal.connection.select_one(
          <<~SQL
            select max(cp.concept_product_id) as last_concept_product_id
            from concept_products cp
            join xpdm_product_memberships xpm on xpm.pdm_object_id = cp.source_product_id
            join concept_skus cs on cs.sku_id = xpm.item_code_name_cd
            where cp.concept_id = 1
              and cs.concept_id = 1
          SQL
        ).fetch('last_concept_product_id', nil)
      end

      private

      def sku_ids_in_batches(arel)
        arel.in_batches.each do |batch_arel|
          # this yields an arel with the ids; use those Ids to go get PDM product_id values
          cp_ids = batch_arel.where_values_hash['concept_product_id']
          source_product_ids = CatModels::ConceptProduct.where(concept_product_id: cp_ids).pluck(:source_product_id)

          # use the PDM product to sku association table to turn those into PDM sku_ids
          pdm_object_ids = External::XPDM::ProductMembershipLocal
                           .where(pdm_object_id: source_product_ids)
                           .distinct
                           .pluck(:item_code_name_cd)
          yield pdm_object_ids
        end
      end

      def transform_batch(engine, includes, pdm_object_ids)
        engine.transform_items(External::XPDM::Sku.preload(includes)
                                 .where(pdm_object_id: pdm_object_ids).skip_query_cache!)
      end
    end
  end
end
