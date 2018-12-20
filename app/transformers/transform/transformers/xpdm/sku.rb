module Transform
  module Transformers
    module XPDM
      class Sku < CatalogTransformer::Base
        source_name 'External::XPDM::Sku'
        match_keys :sku_id, source_key: :pdm_object_id
        include Transform::Transformers::XPDM::WebFlagsSummaryRollup
        include Transform::Transformers::XPDM::WebStatusRollup
        include Transform::Transformers::XPDM::SharedReferences

        has_many :concept_skus, source_name: :concept_skus, match_keys: [:concept], partial: true
        has_many :product_memberships, source_name: :product_memberships, match_keys: [:product_id], partial: true
        has_many :tags, source_name: :cm_tags, match_keys: [:tag_value]
        has_many :promo_attributes, source_name: :promo_attribute_attachments, match_keys: [:promo_cd]

        attribute :sku_id, source_name: :pdm_object_id
        attribute :gtin, source_name: :prmry_upc_num
        attribute :jda_description, association: :description, source_name: :jda_desc
        attribute :pos_description, association: :description, source_name: :pos_desc
        attribute :rollup_type_name, source_name: :rlup_type_name
        attribute :color_family, source_name: :color_grp_name
        attribute :available_in_ca_dist_cd, association: :compliance, source_name: :avail_for_dstrbn_ca_cd
        attribute :transferable_to_canada, association: :compliance, source_name: :transfrbl_to_ca_ind,
                                           default_value: false
        attribute :ca_fulfillment_cd, association: :compliance, source_name: :ec_fulfil_rule_ca_cd
        attribute :ca_fulfillment_name, association: :compliance, source_name: :ec_fulfil_rule_ca_name
        attribute :tbs_blocked_reason_cd, association: :web_info, source_name: :blck_rsn_cd
        attribute :tbs_blocked_reason_name, association: :web_info, source_name: :blck_rsn_name
        attribute :restock_notifiable, association: :web_info, source_name: :email_cust_for_oos_ind
        attribute :vdc_min_days_to_ship, association: :logistics, source_name: :vdc_min_day_to_shp
        attribute :vdc_max_days_to_ship, association: :logistics, source_name: :vdc_max_day_to_shp
        attribute :vdc_sku, association: :logistics, source_name: :vdc_ind, default_value: false

        # TODO: unit of measure
        # TODO: non-taxable
        exclude :category_id, :unit_of_measure_cd, :non_taxable, :web_status, :ecom_status, :units_sold_last_1_week,
                :units_sold_last_4_weeks, :units_sold_last_8_weeks, :units_sold_last_52_weeks,
                allow_primary_key: true

        # manually building this because the TransformerNonActiveRecordModel's need a little help
        def self.source_includes
          [{ item_vendor: { concept_vendor: :vendor } },
           { concept_brand: :brand },
           { eph_tree_node: :tree },
           { merch_dept_tree_node: :tree }, { merch_sub_dept_tree_node: :tree }, { merch_class_tree_node: :tree },
           { product_memberships: { product: [{ bbby_site_navigation: { site_nav_tree_node: :tree } },
                                              { ca_site_navigation: { site_nav_tree_node: :tree } },
                                              { baby_site_navigation: { site_nav_tree_node: :tree } }] } },
           :states, :descriptions, :image_relation, :web_prices, :web_costs, :assembly_dimensions, :package_dimensions,
           { promo_attribute_attachments: :all_concept_flags },
           :item_picture, :web_info, :web_info_sites, :logistics, :compliance, :cm_tags]
        end

        # not tested yet
        # def self.taget_includes
        #   super + (concept_skus: { concept_vendor: [:concept, :vendor] })
        # end

        def assign_web_flags_summary(target)
          target.web_flags_summary = web_flags_summary_rollup(target.concept_skus)
        end

        def assign_web_status(target)
          target.web_status = web_status_rollup(target.concept_skus)
        end

        # this has been moved to the concept sku image transformer
        # after_transform do |target|
        #   images = target.concept_skus.first.concept_sku_images
        #                  .reject { |csi| csi.sku_image_id.present? }
        #                  .map { |csi| CatModels::SkuImage.new(sku: target, image_url: csi.image_url) }
        #                  .index_by(&:image_url)
        #   target.concept_skus.flat_map(&:concept_sku_images)
        #         .select { |csi| images.key?(csi.image_url) }
        #         .each { |csi| csi.sku_image = images[csi.image_url] }
        # end

        module Decorations
          def vmf
            false
          end

          def vintage
            false
          end

          # testing with subsets sometimes brings in only one of a sku's products, so this just excludes the others
          def product_memberships
            super.reject { |pm| pm.concept_product.nil? }
          end
        end
      end
    end
  end
end
