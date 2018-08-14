module External
  module XPDM
    class MissingImagesLoader
      def base_arel
        External::XPDM::Sku
          .beyond_sku
          .select(:pdm_object_id)
          .joins(:image_relation)
          .joins('left outer join "PDM_LU_DGTL_ASSET" ON "PDM_LU_DGTL_ASSET"."DGTL_ASSET_ITEM_ID" = "PDM_ITEM_RLTN"."ITEM_CODE_NAME_CD"') # rubocop:disable Metrics/LineLength
          .group(:pdm_object_id).having('max("PDM_LU_DGTL_ASSET"."IMAGE_FILE_NAME") is null')
      end

      def transformer_class
        Transform::Transformers::XPDM::ConceptSkuImage
      end

      def transform(engine, arel)
        arel.in_batches(of: 10_000) do |batch_arel|
          batch_arel.where_values_hash['pdm_object_id'].in_groups_of(1_000) do |sku_ids|
            transform_images(engine, sku_ids)
          end
        end
      end

      private

      def transform_images(engine, sku_ids)
        images = images_by_sku_id(sku_ids)

        # if the concept skus do not exist for a sku, then the images are just skipped
        concept_skus(sku_ids).each do |cs|
          images[cs.sku_id].each do |image|
            engine.transform_item(image, find_concept_sku_image(cs, image) || cs.concept_sku_images.build)
          end
          cs.concept_sku_images.map(&:sku_image).select(&:changed?).each(&:save)
        end
      end

      def images_by_sku_id(sku_ids)
        alt_image_sequences =
          External::ECOM::Item.alt_image_count_only.where(sku: sku_ids).pluck(:sku, :zoom_indexes).to_h
        External::XPDM::ImageRelation.where(pdm_object_id: sku_ids).each_with_object({}) do |image_relation, memo|
          suffixes_for_sku = alt_image_sequences[image_relation.pdm_object_id]&.split(',') || []
          images = [External::XPDM::Image.new(image_relation)] +
                   suffixes_for_sku.map { |suffix| External::XPDM::Image.new(image_relation, suffix) }
          memo[image_relation.pdm_object_id] = images
        end
      end

      def concept_skus(sku_ids)
        CatModels::ConceptSku.where(sku_id: sku_ids, concept_id: [1, 2, 4])
                             .includes(:sku, concept_sku_images: :sku_image)
      end

      def find_concept_sku_image(concept_sku, image)
        concept_sku.concept_sku_images.find do |csi|
          csi.source_sku_image_id == image.image_asset_id &&
            csi.sort_order == (image.alt_index + 1) * 1_000
        end
      end
    end
  end
end
