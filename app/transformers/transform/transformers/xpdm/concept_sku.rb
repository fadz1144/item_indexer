module Transform
  module Transformers
    module XPDM
      class ConceptSku < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptSku'
        include Transform::Transformers::XPDM::SharedConceptReferences

        attribute :sku_id, association: :sku, source_name: :pdm_object_id
        attribute :source_sku_id, association: :sku, source_name: :pdm_object_id
        attribute :vendor_sku, association: :sku, source_name: :pmry_vdr_part_modl_num
        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :web_offer_date, source_name: :web_offer_dt
        attribute :web_enable_date, source_name: :web_enable_dt
        attribute :pattern_cd, association: :sku
        attribute :pattern_name, association: :sku
        attribute :size_cd, association: :sku
        attribute :size_name, association: :sku
        attribute :color, association: :sku, source_name: :color_name

        has_one :concept_sku_dimensions
        has_one :concept_sku_pricing
        has_many :concept_sku_images, source_name: :concept_sku_images, match_keys: [:image_url]

        exclude :concept_category_id, :status_reason_cd, :era, :style, :materials, :care_instructions,
                :care_instructions_other, :lead_time, :lead_time_bucket, :aad_min_offset_days, :aad_max_offset_days,
                :ltl_eligible, :threshold_eligible, :shipping_method,
                :total_avail_qty, :warehouse_avail_qty, :stores_avail_qty, :vdc_avail_qty, :on_order_qty, :limited_qty,
                :allow_exposure, :returnable, :made_to_order, :assembly_required,
                :exclusivity_tier, :suspended_reason,
                :finish

        after_transform :conditionally_load_inventory

        def conditionally_load_inventory(target)
          return unless @source.sku.association(:inventory).loaded? && @source.sku.inventory.present?
          return if @source.canadian_sku_not_sellable_there?

          %w[total_avail_qty warehouse_avail_qty vdc_avail_qty].each do |name|
            target.public_send("#{name}=", @source.public_send(name))
          end
        end

        module Decorations
          def concept
            Transform::ConceptCache.fetch(concept_id)
          end

          def name
            mstr_prod_desc.presence || prod_desc.presence || vdr_web_prod_desc
          end

          def active
            live || web_status_flg == 'A'
          end

          def live
            live_on_site?
          end

          def status
            active ? 'Active' : 'Inactive'
          end

          def web_offered
            web_offer_ind == 'Y'
          end

          def web_disabled
            web_dsable_ind == 'Y'
          end

          def tbs_blocked
            blck_status_ind == 'Y'
          end

          def total_avail_qty
            afs_qty + alt_afs_qty
          end

          def warehouse_avail_qty
            warehouse_inventory? ? total_avail_qty : 0
          end

          def vdc_avail_qty
            vdc_inventory? ? total_avail_qty : 0
          end

          def canadian_sku_not_sellable_there?
            concept_id == 2 && !sku&.compliance&.sellable_in_canada?
          end
        end
      end
    end
  end
end
