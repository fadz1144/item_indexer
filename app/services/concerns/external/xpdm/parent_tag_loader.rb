module External
  module XPDM
    # = Parent Tag Loader
    #
    # Module ParentTagLoader leverages the ParentTag transformer to load tags for a Product or Sku. The including class
    # must implement methods base_arel and fetch_indexed_parents.
    module ParentTagLoader
      def transformer_class
        Transform::Transformers::XPDM::ParentTag
      end

      def transform(engine, arel)
        arel.in_batches do |cm_tags|
          grouped = cm_tags.group_by(&:pdm_object_id)
          parents = fetch_indexed_parents(grouped.keys)

          grouped.each do |pdm_object_id, tags_for_parent|
            parent = parents[pdm_object_id]
            next if parent.nil?

            tags_for_parent.each { |cm_tag| engine.transform_item(cm_tag, CatModels::Tag.new(taggable: parent)) }
          end
        end
      end
    end
  end
end
