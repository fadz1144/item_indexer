module Transform
  module Transformers
    module XPDM
      class ConceptSku < CatalogTransformer::Base
        source_name 'External::XPDM::ConceptSku'
        include Transform::Transformers::XPDM::SharedConceptReferences
        include Transform::Transformers::XPDM::SharedConceptAttributes

        attribute :sku_id, association: :sku, source_name: :pdm_object_id
        attribute :source_sku_id, association: :sku, source_name: :pdm_object_id
        attribute :vendor_sku, association: :sku, source_name: :pmry_vdr_part_modl_num
        attribute :description, source_name: :mstr_shrt_desc
        attribute :details, source_name: :mstr_web_desc
        attribute :pattern_cd, association: :sku
        attribute :pattern_name, association: :sku
        attribute :size_cd, association: :sku
        attribute :size_name, association: :sku
        attribute :color, association: :sku, source_name: :color_name
        attribute :color_cd, association: :sku, source_name: :color_cd
        attribute :ltl_eligible, association: :sku, source_name: :ltl_item_ind
        attribute :assembly_offered, association: :sku, source_name: :asmbly_offer_ind
        attribute :max_assembly_time, association: :sku, source_name: :max_asmbly_tm_unit
        attribute :actual_created_date, association: :sku, source_name: :item_create_on

        has_one :concept_sku_dimensions
        has_one :concept_sku_pricing
        has_many :concept_sku_images, source_name: :concept_sku_images, match_keys: [:image_url]

        exclude :concept_category_id, :status_reason_cd, :era, :style, :materials, :care_instructions,
                :care_instructions_other, :lead_time, :lead_time_bucket, :aad_min_offset_days, :aad_max_offset_days,
                :threshold_eligible,
                :total_avail_qty, :warehouse_avail_qty, :stores_avail_qty, :vdc_avail_qty, :on_order_qty, :limited_qty,
                :allow_exposure, :returnable, :made_to_order, :assembly_required,
                :exclusivity_tier, :suspended_reason,
                :finish, :site_nav_tree_node_id, :color_group_name, :color_group_cd

        after_transform :conditionally_load_inventory

        def conditionally_load_inventory(target)
          return unless @source.sku.association(:inventory).loaded? && @source.sku.inventory.present?
          return if @source.canadian_sku_not_sellable_there?

          %w[total_avail_qty warehouse_avail_qty vdc_avail_qty].each do |name|
            target.public_send("#{name}=", @source.public_send(name))
          end
        end

        module Decorations
          include Transform::Transformers::XPDM::SharedConceptMethods

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

          def tbs_blocked
            blck_status_ind == 'Y'
          end

          def total_avail_qty
            afs_qty + alt_afs_qty
          end

          def warehouse_avail_qty
            # warehouse_inventory? ? total_avail_qty : 0
            warehouse_inventory? ? afs_qty : 0
          end

          def vdc_avail_qty
            vdc_inventory? ? total_avail_qty : 0
          end

          def stores_avail_qty
            warehouse_inventory ? concept_quantity(concept_id) : 0
          end

          def concept_quantity(concept_id)
            case concept_id
            when 1
              bbb_alt_afs_qty
            when 2
              ca_alt_afs_qty
            when 4
              bab_alt_afs_qty
            else
              raise "Unknown concept_id (#{concept_id}) for ECOM Inventory"
            end
          end

          def canadian_sku_not_sellable_there?
            concept_id == 2 && !sku&.compliance&.sellable_in_canada?
          end

          def shipping_method
            if sku.ltl_item_ind
              sku.truck_shipping_methods_string
            else
              'Standard'
            end
          end
        end
      end
    end
  end
end
