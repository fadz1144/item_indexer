## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class SkuSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::Decorators::AnyDecoratedAttribute
    include SOLR::Decorators::ConceptSkuDetectDecoratedAttribute
    include SOLR::Decorators::ConceptSkuUniqDecoratedAttribute
    include SOLR::Decorators::FieldUniqDecoratedAttribute
    include SOLR::Decorators::PricingDecoratedAttribute
    include SOLR::Decorators::SkuUniqDecoratedAttribute
    include SOLR::Decorators::TreeNodeDecoratedAttribute

    attribute :id
    ProductCoreFields.sku_fields.map do |field|
      attribute field.source_name, key: field.name
    end

    # these attributes do not exist
    stub_attributes :brand_code

    decorate_any 'live', field: 'live'

    decorate_concept_sku_uniq 'brand_id', field: 'concept_brand_id'
    decorate_concept_sku_uniq 'brand_name', field: 'display_brand'
    decorate_concept_sku_uniq 'description', field: 'description'

    decorate_concept_sku_detect 'name', field: 'name'
    decorate_concept_sku_detect 'external_image_url', field: 'primary_image'

    decorate_field_uniq 'concept_id', field: 'concept_id'
    decorate_field_uniq 'exclusivity_tier', field: 'exclusivity_tier'
    decorate_field_uniq 'limited_qty', field: 'limited_qty', group: 'first'
    decorate_field_uniq 'min_aad_offset_days', field: 'aad_min_offset_days', group: 'min'
    decorate_field_uniq 'max_aad_offset_days', field: 'aad_max_offset_days', group: 'max'
    decorate_field_uniq 'on_order_qty', field: 'on_order_qty', group: 'max'
    decorate_field_uniq 'shipping_method', field: 'shipping_method'
    decorate_field_uniq 'store_avail_qty', field: 'stores_avail_qty', group: 'max'
    decorate_field_uniq 'total_avail_qty', field: 'total_avail_qty', group: 'max'
    decorate_field_uniq 'vdc_avail_qty', field: 'vdc_avail_qty', group: 'max'
    decorate_field_uniq 'vendor_sku', field: 'vendor_sku', group: 'max'
    decorate_field_uniq 'warehouse_avail_qty', field: 'warehouse_avail_qty', group: 'max'

    decorate_pricing 'cost', field: 'cost', group: 'max'
    decorate_pricing 'cost_cents', field: 'cost', group: 'max', format: 'currency_cents'
    decorate_pricing 'margin_percent', field: 'margin_percent', group: 'max'
    decorate_pricing 'min_price', field: 'retail_price', group: 'min', format: 'currency'
    decorate_pricing 'max_price', field: 'retail_price', group: 'max', format: 'currency'
    decorate_pricing 'min_price_cents', field: 'retail_price', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_price_cents', field: 'retail_price', group: 'max', format: 'currency_cents'
    decorate_pricing 'min_margin_amount', field: 'margin_amount', group: 'min'
    decorate_pricing 'max_margin_amount', field: 'margin_amount', group: 'max'
    decorate_pricing 'min_margin_amount_cents', field: 'margin_amount', group: 'min', format: 'currency_cents'
    decorate_pricing 'max_margin_amount_cents', field: 'margin_amount', group: 'max', format: 'currency_cents'
    decorate_pricing 'pre_markdown_price', field: 'pre_markdown_price', group: 'max'
    decorate_pricing 'pre_markdown_price_cents', field: 'pre_markdown_price', group: 'max', format: 'currency_cents'

    # contribution margin
    decorate_pricing 'min_contribution_margin_amount_cents', field: 'contribution_margin_amount', group: 'min',
                                                             format: 'currency_cents'
    decorate_pricing 'max_contribution_margin_amount_cents', field: 'contribution_margin_amount', group: 'max',
                                                             format: 'currency_cents'
    decorate_pricing 'min_contribution_margin_percent', field: 'contribution_margin_percent', group: 'min'
    decorate_pricing 'max_contribution_margin_percent', field: 'contribution_margin_percent', group: 'max'

    # fetch directly from the sku
    decorate_sku_uniq 'pdp_url', field: 'pdp_urls'
    decorate_sku_uniq 'vendor_id', field: 'vendor_id'
    decorate_sku_uniq 'vendor_name', field: 'vendor_name'

    decorate_sku_uniq 'color', field: 'color_family'

    # hierarchies
    decorate_tree_node 'eph_tree_node_id', tree: 'eph', field: 'id'
    decorate_tree_node 'eph_tree_source_code', tree: 'eph', field: 'source_code'
    decorate_tree_node 'eph_tree_node_name', tree: 'eph', field: 'name'

    decorate_tree_node 'merch_tree_node_id', tree: 'merch', field: 'id'
    decorate_tree_node 'merch_tree_source_code', tree: 'merch', field: 'source_code'
    decorate_tree_node 'merch_tree_node_name', tree: 'merch', field: 'name'

    #   { name: 'bbby_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'bbby_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'bbby_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'ca_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_node_id', type: 'long', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_source_code', type: 'string', indexed: true, stored: true, multiValued: true },
    #   { name: 'baby_site_nav_tree_node_name', type: 'text_general', indexed: true, stored: true, multiValued: true },

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

    def id
      "S#{object.sku_id}"
    end

    def product_id
      object.product_ids
    end

    def doc_type
      'sku'
    end

    def upc_ean
      object.gtin
    end

    # TODO: implement me
    def long_description
      ''
    end

    def owned_available
      store_avail_qty + warehouse_avail_qty
    end

    def vendor_remaining
      vdc_avail_qty
    end

    # TODO: implement me
    def msrp
      0
    end

    # TODO: implement me
    def msrp_cents
      0
    end

    # TODO: implement me
    def commission_percent
      0
    end

    def category_id
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:id)
    end

    def category_name
      CatModels::CategoryCache.hierarchy_for(object.category&.category_id).map(&:name).uniq
    end

    # TODO: implement me
    def eph_category_id
      []
    end

    # TODO: implement me
    def eph_category_name
      ''
    end

    def dimensions
      service.concept_skus_iterator_uniq(&:dimensions) || []
    end

    def inventory?
      total_avail_qty.present? && total_avail_qty > 0
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

    def web_status
      # values should be 'Active', 'In Progress', 'Suspended', 'Buyer Reviewed'
      status = WEB_STATUS_TO_DISPLAY_VALUE.keys.map do |method_name|
        WEB_STATUS_TO_DISPLAY_VALUE[method_name] if send("#{method_name}?".to_sym)
      end.compact

      status.presence ? status : nil
    end

    WEB_STATUS_TO_DISPLAY_VALUE = {
      web_status_buyer_reviewed: 'Buyer Reviewed',
      web_status_in_progress: 'In Progress',
      web_status_active: 'Active',
      web_status_suspended: 'Suspended'
    }.freeze

    WEB_STATUS_TO_DISPLAY_VALUE.keys.each do |method_name|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method_name}?
          object.send("#{method_name}".to_sym).present?
        end
      RUBY
    end

    # TODO: implement these methods BELOW

    private

    def service
      @service ||= Serializers::DecoratedSkusSerializerService.new(Serializers::SkuDecoratorWrapper.new(object))
    end
  end
end
