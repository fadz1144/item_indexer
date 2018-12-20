## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class ProductSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::Decorators::AnyDecoratedAttribute
    include SOLR::Decorators::ConceptSkuDetectDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedAttribute
    include SOLR::Decorators::FieldUniqDecoratedAttribute
    include SOLR::Decorators::PricingDecoratedAttribute
    include SOLR::Decorators::SkuUniqDecoratedAttribute
    include SOLR::Decorators::TreeNodeDecoratedAttribute
    include SOLR::Decorators::ConstantAttributeBuckets

    attribute :id
    attribute :skus, key: :_childDocuments_

    ProductCoreFields.product_fields.map do |field|
      attribute field.source_name, key: field.name
    end

    # these attributes do not exist
    stub_attributes :allow_exposure, :units_sold_last_1_week, :units_sold_last_4_weeks, :units_sold_last_8_weeks,
                    :units_sold_last_52_weeks, :vdc_sku, :vintage

    decorate_concept_sku_uniq 'brand_id', field: 'concept_brand_id'
    decorate_concept_sku_uniq 'brand_name', field: 'display_brand'
    decorate_concept_sku_uniq 'sku_id', field: 'sku_id'

    decorate_field_uniq 'exclusivity_tier', field: 'exclusivity_tier'
    decorate_field_uniq 'min_aad_offset_days', field: 'aad_min_offset_days', group: 'min'
    decorate_field_uniq 'max_aad_offset_days', field: 'aad_max_offset_days', group: 'max'
    decorate_field_uniq 'min_lead_time', field: 'lead_time', group: 'min'
    decorate_field_uniq 'max_lead_time', field: 'lead_time', group: 'max'
    decorate_field_uniq 'shipping_method', field: 'shipping_method'
    decorate_field_uniq 'web_status', field: 'web_status'

    decorate_pricing 'min_margin_amount', field: 'margin_amount', group: 'min'
    decorate_pricing 'min_margin_amount', field: 'margin_amount', group: 'min'
    decorate_pricing 'max_margin_amount', field: 'margin_amount', group: 'max'
    decorate_pricing 'min_price', field: 'retail_price', group: 'min', format: 'currency'
    decorate_pricing 'max_price', field: 'retail_price', group: 'max', format: 'currency'
    decorate_pricing 'min_price_cents', field: 'retail_price', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_price_cents', field: 'retail_price', group: 'max', format: 'currency_cents'
    decorate_pricing 'min_margin_amount_cents', field: 'margin_amount', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_margin_amount_cents', field: 'margin_amount', group: 'max', format: 'currency_cents'
    decorate_pricing 'avg_margin_percent', field: 'margin_percent', group: 'avg'

    # contribution margin
    decorate_pricing 'min_contribution_margin_amount_cents', field: 'contribution_margin_amount', group: 'min',
                                                             format: 'currency_cents'
    decorate_pricing 'max_contribution_margin_amount_cents', field: 'contribution_margin_amount', group: 'max',
                                                             format: 'currency_cents'
    decorate_pricing 'min_contribution_margin_percent', field: 'contribution_margin_percent', group: 'min'
    decorate_pricing 'max_contribution_margin_percent', field: 'contribution_margin_percent', group: 'max'

    decorate_sku_uniq 'pdp_url', field: 'pdp_urls'
    decorate_sku_uniq 'vendor_id', field: 'vendor_id'
    decorate_sku_uniq 'vendor_name', field: 'vendor_name'

    decorate_sku_uniq 'web_status_buyer_reviewed', field: 'web_status_buyer_reviewed'
    decorate_sku_uniq 'web_status_in_progress', field: 'web_status_in_progress'
    decorate_sku_uniq 'web_status_active', field: 'web_status_active'
    decorate_sku_uniq 'web_status_suspended', field: 'web_status_suspended'

    decorate_tree_node 'eph_tree_node_id', tree: 'eph', field: 'id'
    decorate_tree_node 'eph_tree_source_code', tree: 'eph', field: 'source_code'
    decorate_tree_node 'eph_tree_node_name', tree: 'eph', field: 'name'

    decorate_tree_node 'merch_tree_node_id', tree: 'merch', field: 'id'
    decorate_tree_node 'merch_tree_source_code', tree: 'merch', field: 'source_code'
    decorate_tree_node 'merch_tree_node_name', tree: 'merch', field: 'name'

    decorate_tree_node 'bbby_site_nav_tree_node_id', tree: 'bbby_site_nav', field: 'id'
    decorate_tree_node 'bbby_site_nav_tree_source_code', tree: 'bbby_site_nav', field: 'source_code'
    decorate_tree_node 'bbby_site_nav_tree_node_name', tree: 'bbby_site_nav', field: 'name'

    decorate_tree_node 'ca_site_nav_tree_node_id', tree: 'ca_site_nav', field: 'id'
    decorate_tree_node 'ca_site_nav_tree_source_code', tree: 'ca_site_nav', field: 'source_code'
    decorate_tree_node 'ca_site_nav_tree_node_name', tree: 'ca_site_nav', field: 'name'

    decorate_tree_node 'baby_site_nav_tree_node_id', tree: 'baby_site_nav', field: 'id'
    decorate_tree_node 'baby_site_nav_tree_source_code', tree: 'baby_site_nav', field: 'source_code'
    decorate_tree_node 'baby_site_nav_tree_node_name', tree: 'baby_site_nav', field: 'name'

    bucket 'web_flags_summary', CatModels::Constants::WebFlagsSummary

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

    #   { name: 'baby_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },

    def id
      "P#{object.product_id}"
    end

    def concept_id
      concept_ids = []
      service.concept_skus_iterator do |cs|
        concept_ids << cs.concept_id if include_concept?(cs, cs.concept_id)
      end
      concept_ids.uniq
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

    def source_product_id
      object.concept_products&.map(&:source_product_id)&.uniq
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

    def inventory?
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

    def include_concept?(concept_sku, concept_id)
      case concept_id
      when 1, 3 # bed bath and okl
        true
      when 2 # canada
        # TODO: this should be in a decorator
        concept_sku.sku&.available_in_canada? || concept_sku.sku&.transfrbl_to_ca_ind?
      when 4 # baby
        # tree_node = concept_sku.baby_site_nav
        # tree_node&.map(:baby_site_nav_id).present?
        offered?(concept_sku)
      else
        false
      end
    end

    def offered?(concept_sku)
      concept_sku.web_offered || concept_sku.web_enable_date.present? || concept_sku.web_offer_date.present?
    end

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::ProductDecoratorWrapper.new(object))
    end
  end
end
