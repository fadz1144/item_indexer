module External
  module XPDM
    class SkuLoader
      def initialize(include_inventory = true)
        @include_inventory = include_inventory
      end

      def base_arel
        External::XPDM::Sku.beyond_sku
      end

      def transformer_class
        Transform::Transformers::XPDM::Sku
      end

      def transform(engine, arel)
        includes = Transform::Transformers::XPDM::Sku.source_includes
        includes << :inventory if @include_inventory
        arel.preload(includes).in_batches do |skus|
          raise '-- Transformers recalled --' if take_a_break?
          engine.transform_items(skus)
        end
      end

      # that's the start of the full load (it excludes the small set of skus brought over in the partial load)
      def restart_id
        CatModels::ConceptSku.where.not(concept_id: 3).where("updated_at > '2018-10-07 22:19:26.860884'")
                             .maximum(:sku_id)
      end

      private

      def take_a_break?
        # the updated_by column on the EPH tree is standing in for the Take a Break flag
        CatModels::Tree.find(1).source_updated_by == 1
      end
    end
  end
end
