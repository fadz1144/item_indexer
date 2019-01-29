module Inbound
  module DW
    class ContributionMarginFeed < ApplicationRecord
      belongs_to :inbound_batch, class_name: 'Inbound::Batch'
      def self.table_name_prefix
        'inbound_dw_'
      end

      def self.table_name
        'inbound_dw_contribution_margin_feed'
      end

      def self.inbound_batch_fields
        { data_type: 'sku_pricing', source: 'DW' }.freeze
      end

      SITE_ID_TO_CONCEPT = {
        'BedBathUS' => 1,
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
        'Unrecognized value in SITE_ID field from mft: %d. We only expect values in (%s)' % [
          site_id,
          SITE_ID_TO_CONCEPT.keys.join('|')
        ]
      end
    end
  end
end
