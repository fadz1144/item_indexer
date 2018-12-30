module External
  module XPDM
    class PromoAttributeDefinition < External::XPDM::Base
      HTML_SANITIZER = Rails::Html::FullSanitizer.new
      self.table_name = 'pdm_lu_promo_attrib'
      INCLUDED_COLUMNS = %i[promo_cd promo_atrib_val_name promo_atrib_html_val_name
                            image_url actn_url create_ts update_ts].freeze

      attribute :promo_atrib_html_val_name, :xpdm_string

      # This strips tags
      def site_description
        HTML_SANITIZER.sanitize(promo_atrib_html_val_name)
      end

      def self.cached_find(promo_cd)
        actual_promo_cd = promo_cd.split(/[^0-9_]/, 2).first
        @cache ||= all.select(INCLUDED_COLUMNS).index_by(&:promo_cd)
        @cache.fetch(actual_promo_cd) do
          External::XPDM::PromoAttributeDefinition.new(promo_cd: actual_promo_cd,
                                                       promo_atrib_val_name: promo_cd,
                                                       promo_atrib_html_val_name: promo_cd)
        end
      end
    end
  end
end
