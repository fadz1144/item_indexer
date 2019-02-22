module Transform
  module Transformers
    module OKL
      class ConceptSku < CatalogTransformer::Base
        source_name 'Inbound::OKL::SkuRevision'
        match_keys :source_sku_id
        decorator_name 'Transform::Transformers::OKL::Decorators::SkuConceptSkuDecorator'

        belongs_to :sku, match_keys: [:sku_id]
        has_one :concept_sku_dimensions, source_name: :dimensions
        has_one :concept_sku_pricing
        has_many :concept_sku_images, source_name: :images, match_keys: [:source_sku_image_id]
        has_many :concept_sku_attributes, source_name: :sku_attributes, match_keys: [:code]

        attribute :status_reason_cd, association: :state, source_name: :obsolete_reason_id
        attribute :suspended_reason, association: :state, source_name: :obsolete_reason_name
        attribute :exclusivity_tier, association: :state
        attribute :lead_time, association: :shipping
        attribute :aad_min_offset_days, association: :shipping, source_name: :min_aad_offset_days
        attribute :aad_max_offset_days, association: :shipping, source_name: :max_aad_offset_days
        attribute :ltl_eligible, association: :shipping, source_name: :white_glove
        attribute :total_avail_qty, association: :inventory
        attribute :warehouse_avail_qty, association: :inventory
        attribute :stores_avail_qty, association: :inventory
        attribute :vdc_avail_qty, association: :inventory
        attribute :on_order_qty, association: :inventory

        exclude :site_nav_tree_node_id, :web_offered, :web_disabled, :web_offer_date, :web_enable_date, :details,
                :force_below_the_line, :pattern_cd, :pattern_name, :size_cd, :size_name, :finish, :tbs_blocked

        def self.target_relation
          super.where(concept_id: CONCEPT_ID)
        end

        before_transform :handle_sku_id_change
        after_save :destroy_sku_with_previous_id

        module Decorations
          REGEX_MADE_TO_ORDER = /(cut|made|finished) to order/i
          REGEX_ASSEMBLY_REQUIRED = /(?<!no )assembly (may be )?(is )?required/i

          def concept_id
            CONCEPT_ID
          end

          def source_created_at
            super || '1976-07-06'.to_datetime
          end

          def live
            active? && allow_exposure && inventory.present? && !inventory.total_avail_qty.zero? &&
              state.exists_in_storefront && state.obsolete_reason_id.nil?
          end

          # TODO: how does lead_time_bucket get calculated?
          def lead_time_bucket
            nil
          end

          def shipping_method
            if threshold_eligible
              'Threshold, White Glove'
            elsif shipping.white_glove?
              'White Glove'
            else
              'Standard'
            end
          end

          # Being not white glove means it ships parcel, which renders the entryway/threshold flag moot.
          def threshold_eligible
            shipping.white_glove? && shipping.entryway?
          end

          def limited_qty
            inventory.nil? || inventory.total_avail_qty.nil? || inventory.total_avail_qty < 5
          end

          # value can be null in inbound table, but is required as boolean in polished table
          def returnable
            shipping.returnable.presence || false
          end

          def made_to_order
            made_to_order_attribute == '1'
          end

          def assembly_required
            REGEX_ASSEMBLY_REQUIRED.match(please_note).present?
          end

          private

          def please_note
            @please_note ||= sku_attributes.find { |a| a.code = 'please_note' }&.value || ''
          end

          def made_to_order_attribute
            @made_to_order_attribute ||= sku_attributes.find { |a| a.code = 'made_to_order' }&.value
          end
        end

        def handle_sku_id_change(target)
          return unless sku_id_changed?(target)

          @sku_id_to_retire = target.sku_id
          target.sku = CatModels::Sku.find_or_initialize_by(sku_id: @source.sku_id)
        end

        def destroy_sku_with_previous_id(_target)
          return if @sku_id_to_retire.blank?
          CatModels::Sku.destroy(@sku_id_to_retire)
        end

        private

        def sku_id_changed?(target)
          target.persisted? && target.sku_id != @source.sku_id
        end
      end
    end
  end
end
