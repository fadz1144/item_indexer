module Transform
  module Transformers
    module XPDM
      class PromoAttributeConceptFlag < CatalogTransformer::Base
        source_name 'External::XPDM::PromoAttributeAttachmentConceptFlag'
        exclude :promo_attribute_id

        attribute :applies, source_name: :promo_vld_status_ind
      end
    end
  end
end
