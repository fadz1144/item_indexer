module External
  module XPDM
    # this doubles as the base class for SkuWebStatusBackfill
    class ProductWebStatusBackfill
      include Transform::Transformers::ConstantRollupBuilder

      # on the parent, we only need pdm_object_id
      def base_arel
        model.no_updates_since('2018-11-04'.to_datetime)
      end

      def transformer_class
        Transform::Transformers::XPDM::WebStatus
      end

      def transform(engine, arel)
        arel.in_batches(of: 10_000) do |batch_arel|
          batch_arel.where_values_hash['pdm_object_id'].in_groups_of(100) do |pdm_object_ids|
            source_records = load_source_records(pdm_object_ids)
            target_records = load_indexed_targets(pdm_object_ids)

            source_records.each do |source|
              target = target_records[source.pdm_object_id]
              engine.transform_item(source, target) if target.present?
            end
          end
        end
      end

      private

      def model
        External::XPDM::Product.web_product
      end

      def load_source_records(pdm_object_ids)
        External::XPDM::Item.select(:pdm_object_id).includes(:web_info_sites).where(pdm_object_id: pdm_object_ids)
      end

      def load_indexed_targets(pdm_object_ids)
        target_records(pdm_object_ids).index_by { |p| p.concept_products.first.source_product_id }
      end

      def target_records(pdm_object_ids)
        CatModels::Product.includes(:brand, :vendor, concept_products: %i[concept concept_brand concept_vendor])
                          .references(:concept_products)
                          .merge(CatModels::ConceptProduct.where(source_product_id: pdm_object_ids,
                                                                 concept_id: [1, 2, 4]))
      end
    end
  end
end
