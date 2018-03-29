module Transform
  module Transformers
    module OKL
      class ConceptSku < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        match_keys :source_sku_id

        belongs_to :sku
        has_one :concept_sku_dimensions, source_name: :dimensions
        has_one :concept_sku_pricing
        has_many :concept_sku_images, source_name: :images, match_keys: [:source_sku_image_id]
        has_many :concept_sku_attributes, source_name: :sku_attributes, match_keys: [:code]

        attribute :status_reason_cd, association: :state, source_name: :obsolete_reason_id
        attribute :exclusivity_tier, association: :state
        attribute :lead_time, association: :shipping
        attribute :aad_min_offset_days, association: :shipping, source_name: :min_aad_offset_days
        attribute :aad_max_offset_days, association: :shipping, source_name: :max_aad_offset_days
        attribute :ltl_eligible, association: :shipping, source_name: :white_glove
        attribute :threshold_eligible, association: :shipping, source_name: :entryway
        attribute :total_avail_qty, association: :inventory
        attribute :warehouse_avail_qty, association: :inventory
        attribute :stores_avail_qty, association: :inventory
        attribute :vdc_avail_qty, association: :inventory
        attribute :on_order_qty, association: :inventory

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        module Decorations
          REGEX_MADE_TO_ORDER = /(cut|made|finished) to order/i
          REGEX_ASSEMBLY_REQUIRED = /(?<!no )assembly (may be )?(is )?required/i

          def concept_id
            CONCEPT_ID
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end

          def status
            active? ? 'ACTIVE' : 'INACTIVE'
          end

          def live
            active? && allow_exposure && inventory.present? && !inventory.total_avail_qty.zero? &&
              state.exists_in_storefront
          end

          # TODO: how does lead_time_bucket get calculated?
          def lead_time_bucket
            nil
          end

          def shipping_method
            if shipping.entryway?
              'Threshold, White Glove'
            elsif shipping.white_glove?
              'White Glove'
            else
              'Standard'
            end
          end

          def limited_qty
            inventory.nil? || inventory.total_avail_qty.nil? || inventory.total_avail_qty < 5
          end

          # value can be null in inbound table, but is required as boolean in polished table
          def returnable
            shipping.returnable.presence || false
          end

          def made_to_order
            REGEX_MADE_TO_ORDER.match(please_note).present?
          end

          def assembly_required
            REGEX_ASSEMBLY_REQUIRED.match(please_note).present?
          end

          private

          def please_note
            @memo_please_note ||= sku_attributes.find { |a| a.code = 'please_note' }&.value || ''
          end
        end
      end
    end
  end
end
