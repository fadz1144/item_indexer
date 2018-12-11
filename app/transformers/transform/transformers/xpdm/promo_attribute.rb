module Transform
  module Transformers
    module XPDM
      class PromoAttribute < CatalogTransformer::Base
        source_name 'External::XPDM::PromoAttributeAttachment'
        exclude :item_type, :item_id, :promo_attribute_id

        has_many :concept_flags,
                 transformer_name: 'Transform::Transformers::XPDM::PromoAttributeConceptFlag',
                 match_keys: [:concept_id], source_name: :concept_flags

        attribute :internal_description, source_name: :promo_atrib_val_name
        attribute :site_description
        attribute :associated_image, source_name: :image_url
        attribute :associated_url, source_name: :actn_url
        # See below for begin_date and end_date

        module Decorations
          # These methods ensure that totally fake dates are interpreted correctly.
          def begin_date
            reference_date = [update_ts, create_ts, Time.zone.today].find(&:present?)
            twenty_years_before_year = reference_date.year - 20
            if promo_start_dt.year < twenty_years_before_year
              Date.new(twenty_years_before_year)
            else
              promo_start_dt
            end
          end

          def end_date
            reference_date = [update_ts, create_ts, Time.zone.today].find(&:present?)
            ten_years_into_the_future_year = reference_date.year + 10
            if promo_end_dt.year > ten_years_into_the_future_year
              nil
            else
              promo_end_dt
            end
          end
        end
      end
    end
  end
end
