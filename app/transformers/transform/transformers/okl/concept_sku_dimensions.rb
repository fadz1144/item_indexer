module Transform
  module Transformers
    module OKL
      class ConceptSkuDimensions < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuDimensionsRevision'
        attribute :sku_id, association: :sku
        attribute :source_sku_id, association: :sku

        exclude :concept_sku_id

        module Decorations
          def concept_id
            CONCEPT_ID
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end

          def item_dimension_display
            dimension_display(item_length, item_width, item_height)
          end

          def shipping_dimension_display
            dimension_display(shipping_length, shipping_width, shipping_height)
          end

          private

          def dimension_display(length, width, height)
            # replace nil values with zero's
            clean_length = clean_measurement(length)
            clean_width = clean_measurement(width)
            clean_height = clean_measurement(height)

            return '' if [clean_length, clean_width, clean_height].all? { |m| m == '0' }

            "#{clean_length}\" L x #{clean_width}\" W x #{clean_height}\" H"
          end

          def clean_measurement(measurement)
            ActiveSupport::NumberHelper.number_to_rounded(measurement, precision: 2, strip_insignificant_zeros: true) ||
              '0'
          end
        end
      end
    end
  end
end
