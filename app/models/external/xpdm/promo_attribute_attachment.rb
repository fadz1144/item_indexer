module External
  module XPDM
    class PromoAttributeAttachment < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_promo'
      belongs_to :item, class_name: 'External::XPDM::Item', foreign_key: :pdm_object_id, primary_key: :pdm_object_id,
                        inverse_of: :promo_attribute_attachments
      has_many :all_concept_flags, class_name: 'External::XPDM::PromoAttributeAttachmentConceptFlag',
                                   primary_key: :pdm_object_id, foreign_key: :pdm_object_id, dependent: :destroy
      delegate :promo_atrib_val_name, :site_description, :image_url, :actn_url, to: :attribute_definition

      def concept_flags
        all_concept_flags.to_a.select { |c_flag| c_flag.promo_cd == promo_cd }
      end

      def attribute_definition
        @attribute_definition ||= PromoAttributeDefinition.cached_find(promo_cd)
      end
    end
  end
end
