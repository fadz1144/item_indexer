module Inbound
  module DW
    class DwSalesMetricsFeed < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      def self.table_name_prefix
        'inbound_dw_'
      end

      def self.table_name
        'inbound_dw_sales_metrics_feed'
      end

      def self.inbound_batch_fields
        { data_type: 'sku_pricing', source: 'SALES' }.freeze
      end

      SITE_ID_TO_CONCEPT = {
        'BedbathUS' => 1,
        'BedBathCA' => 2, # A TOTAL GUESS - NEVER SEEN ANY OTHER VALUE BUT BedBathUS
        'BuyBuyBaby' => 4, # A TOTAL GUESS - NEVER SEEN ANY OTHER VALUE BUT BedBathUS
      }.freeze

      def concept_id
        SITE_ID_TO_CONCEPT[site_id] || (raise site_id_error_msg(site_id))
      end

      def compound_source_key
        '%d:%d' % [concept_id, sku_id]
      end

      private

      def site_id_error_msg(site_id)
        'Unrecognized value in SITE_ID field from mft: %s. We only expect values in (%s)' % [
          site_id,
          SITE_ID_TO_CONCEPT.keys.join('|')
        ]
      end
    end
  end
end
