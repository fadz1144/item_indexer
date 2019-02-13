module External
  module XPDM
    class SiteNavigationsBackfill
      attr_reader :base_arel
      def initialize(base_arel, target_class)
        @base_arel = base_arel
        @target_class = target_class
      end

      def transformer_class
        Transform::Transformers::XPDM::SiteNavigationCollection
      end

      def transform(engine, arel)
        arel.in_batches(of: 10_000) do |batch_arel|
          # select 10,000 Ids at a time

          batch_arel.where_values_hash['pdm_object_id'].in_groups_of(1_000) do |pdm_object_ids|
            # then select products / collections 1,000 at a time
            transform_batch(engine, pdm_object_ids)
          end
        end
      end

      private

      def transform_batch(engine, pdm_object_ids)
        target_records = load_target_records(pdm_object_ids)

        # loop through each concept on it's own
        concept_models.each do |concept_id, model|
          source_records = load_source_records(model, pdm_object_ids)

          targets_for_concept_with_source_record(target_records, concept_id, source_records).each do |target|
            engine.transform_item(source_records[target.public_send(source_id_name)], target)
          end
        end
      end

      # fetch the source records, group them by the product Id, then ignore anything without multiple entries
      def load_source_records(model, pdm_object_ids)
        model.where(pdm_object_id: pdm_object_ids)
             .includes(root_tree_node: :tree, branch_tree_node: :tree, leaf_tree_node: :tree)
             .to_a
             .select(&:tree_nodes_valid?)
             .group_by(&:pdm_object_id)
             .reject { |_k, group| group.size < 2 }
      end

      # source_product_id or source_collection_id
      def source_id_name
        @source_id_name ||= @target_class.primary_key.gsub('concept', 'source')
      end

      def load_target_records(pdm_object_ids)
        @target_class
          .where(source_id_name => pdm_object_ids)
          .includes(site_navigations: %i[root_tree_node branch_tree_node leaf_tree_node])
      end

      def targets_for_concept_with_source_record(target_records, concept_id, source_records)
        target_records.select { |r| r.concept_id == concept_id }
                      .select { |r| source_records.key? r.public_send(source_id_name) }
      end

      def concept_models
        { 1 => External::XPDM::BBBYSiteNavigation,
          2 => External::XPDM::BABYSiteNavigation,
          4 => External::XPDM::CASiteNavigation }
      end
    end
  end
end
