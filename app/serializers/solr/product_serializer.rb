## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class ProductSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::RollupAttribute

    attribute :id
    attribute :skus, key: :_childDocuments_

    ProductCoreFields.product_fields.map do |field|
      attribute field[:name].to_sym
    end

    delegate :product_id, to: :object

    rollup 'min_margin_amount', access_type: 'pricing', access_field: 'margin_amount', group: 'min'

    rollup 'min_margin_amount', access_type: 'pricing', access_field: 'margin_amount', group: 'min'
    rollup 'max_margin_amount', access_type: 'pricing', access_field: 'margin_amount', group: 'max'
    rollup 'min_price', access_type: 'pricing', access_field: 'retail_price', group: 'min', format: 'currency'
    rollup 'max_price', access_type: 'pricing', access_field: 'retail_price', group: 'max', format: 'currency'
    rollup 'min_price_cents', access_type: 'pricing', access_field: 'retail_price', group: 'min',
                              format: 'currency_cents'
    rollup 'max_price_cents', access_type: 'pricing', access_field: 'retail_price', group: 'max',
                              format: 'currency_cents'
    rollup 'min_margin_amount_cents', access_type: 'pricing', access_field: 'margin_amount',
                                      group: 'min', format: 'currency_cents'
    rollup 'max_margin_amount_cents', access_type: 'pricing', access_field: 'margin_amount',
                                      group: 'max', format: 'currency_cents'
    rollup 'avg_margin_percent', access_type: 'pricing', access_field: 'margin_percent', group: 'avg'

    rollup 'exclusivity_tier', access_type: 'service', access_field: 'exclusivity_tier'
    rollup 'min_aad_offset_days', access_type: 'service', access_field: 'aad_min_offset_days',
                                  group: 'min'
    rollup 'max_aad_offset_days', access_type: 'service', access_field: 'aad_max_offset_days',
                                  group: 'max'
    rollup 'min_lead_time', access_type: 'service', access_field: 'lead_time', group: 'min'
    rollup 'max_lead_time', access_type: 'service', access_field: 'lead_time', group: 'max'
    rollup 'shipping_method', access_type: 'service', access_field: 'shipping_method'

    rollup 'web_status', access_type: 'service', access_field: 'web_status'
    rollup 'web_status_buyer_reviewed', access_type: 'decorated', access_field: 'web_status_buyer_reviewed'
    rollup 'web_status_in_progress', access_type: 'decorated', access_field: 'web_status_in_progress'
    rollup 'web_status_active', access_type: 'decorated', access_field: 'web_status_active'
    rollup 'web_status_suspended', access_type: 'decorated', access_field: 'web_status_suspended'

    rollup 'concept_id', access_type: 'concept_skus_uniq', access_field: 'concept_id'
    rollup 'vendor_id', access_type: 'concept_skus_uniq', access_field: 'concept_vendor_id'
    rollup 'vendor_name', access_type: 'concept_skus_uniq', access_field: 'concept_vendor_name'
    rollup 'brand_id', access_type: 'concept_skus_uniq', access_field: 'concept_brand_id'
    rollup 'brand_name', access_type: 'concept_skus_uniq', access_field: 'display_brand'

    rollup 'eph_tree_node_id', access_type: 'tree_node', access_sub_type: 'eph', access_field: 'tree_node_id'
    rollup 'eph_tree_source_code', access_type: 'tree_node', access_sub_type: 'eph', access_field: 'source_code'
    rollup 'eph_tree_node_name', access_type: 'tree_node', access_sub_type: 'eph', access_field: 'name'

    # TODO: define rollups for these:
    #   { name: 'allow_exposure', type: 'boolean' indexed: true, stored: true },
    #   { name: 'available_in_ca', type: 'boolean' indexed: true, stored: true },
    #   { name: 'clearance_status', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'concept_eligibility', type: 'int' indexed: true, stored: true, multiValued: true },
    #   { name: 'contribution_margin_percent', type: 'float' indexed: true, stored: true },
    #   { name: 'dynamic_price_eligible', type: 'boolean' indexed: true, stored: true },
    #   { name: 'inactive_reason', type: 'string' indexed: true, stored: true, multiValued: true },
    #   { name: 'inventory_ecom_us', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_ecom_ca', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_okl_branded', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_okl_vintage', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_ropis', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_total', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_store_total', type: 'int' indexed: true, stored: true },
    #   { name: 'inventory_vdc_total', type: 'int' indexed: true, stored: true },
    #   { name: 'jda_status', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'line_of_business', type: 'string' indexed: true, stored: true, multiValued: true },
    #   { name: 'ltl_flag', type: 'boolean' indexed: true, stored: true },
    #   { name: 'personalized', type: 'boolean' indexed: true, stored: true },
    #   { name: 'product_type', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'size', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'tbs_blocked', type: 'int', indexed: true, stored: true, multiValued: true },
    #   { name: 'units_sold_last_week', type: 'int', indexed: true, stored: true },
    #   { name: 'units_sold_last_8_weeks', type: 'int', indexed: true, stored: true },
    #   { name: 'units_sold_last_year', type: 'int', indexed: true, stored: true },
    #   { name: 'vdc_flag', type: 'boolean', indexed: true, stored: true },
    #   { name: 'vintage', type: 'boolean', indexed: true, stored: true },
    #   { name: 'web_enabled_date', type: 'date', indexed: true, stored: true },

    # hierarchy
    #   { name: 'merch_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'merch_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'merch_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
    #   { name: 'bbby_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'bbby_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'bbby_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },

    def serializable_fields
      ProductCoreFields.product_fields
    end

    def id
      "P#{product_id}"
    end

    def skus
      result = []

      object.skus.each do |s|
        result << SOLR::SkuSerializer.new(s).as_json
      end

      result
    end

    def doc_type
      'product'
    end

    def name
      # take the first name of the concept product
      object.concept_products&.map(&:name)&.first
    end

    def category_id
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:id)
    end

    def category_name
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:name).uniq
    end

    # TODO: implement me
    def description
      ''
    end

    # TODO: implement me
    def long_description
      ''
    end

    # TODO: implement me
    def eph_category_id
      []
    end

    # TODO: implement me
    def eph_category_name
      ''
    end

    def color
      service.decorated_skus.map(&:color_family).uniq
    end

    # TODO: implement me
    def internal_color_family
      ''
    end

    def item_status
      # active
      if service.concept_skus_any? { |cs| cs.status == 'Active' }
        ['Active']
      elsif service.concept_skus_any? { |cs| cs.status == 'In Progress' }
        ['In Progress']
      else
        (['Suspended'] + service.field_unique_values(:suspended_reason)).flatten.uniq
      end
    end

    def live
      service.concept_skus_any?(&:live)
    end

    def has_inventory # rubocop:disable PredicateName
      service.concept_skus_any? do |cs|
        cs.total_avail_qty > 0
      end
    end

    private

    def apply_format(result, rollup_field)
      if rollup_field.currency_cents?
        as_currency_cents(result)
      elsif rollup_field.currency?
        as_currency(result)
      else
        result
      end
    end

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::ProductDecoratorWrapper.new(object))
    end
  end
end
