## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class SkuSerializer < BaseSerializer # rubocop:disable ClassLength
    include SOLR::RollupAttribute

    attribute :id
    ProductCoreFields.sku_fields.map do |field|
      attribute field[:name].to_sym
    end

    attribute :inventory?, key: :has_inventory

    delegate :sku_id, to: :object
    delegate :gtin, to: :object
    delegate :vmf, to: :object

    def serializable_fields
      ProductCoreFields.sku_fields
    end

    rollup 'live', access_type: 'concept_skus_any', access_field: 'live'

    rollup 'brand_id', access_type: 'concept_skus_uniq', access_field: 'concept_brand_id'
    rollup 'brand_name', access_type: 'concept_skus_uniq', access_field: 'display_brand'
    rollup 'description', access_type: 'concept_skus_uniq', access_field: 'description'
    rollup 'vendor_id', access_type: 'concept_skus_uniq', access_field: 'concept_vendor_id'
    rollup 'vendor_name', access_type: 'concept_skus_uniq', access_field: 'concept_vendor_name'

    rollup 'color', access_type: 'decorated', access_field: 'color_family'

    rollup 'name', access_type: 'detect', access_field: 'name'
    rollup 'external_image_url', access_type: 'detect', access_field: 'primary_image'

    rollup 'cost', access_type: 'pricing', access_field: 'cost', group: 'max'
    rollup 'cost_cents', access_type: 'pricing', access_field: 'cost', group: 'max', format: 'currency_cents'
    rollup 'margin_percent', access_type: 'pricing', access_field: 'margin_percent', group: 'max'
    rollup 'min_price', access_type: 'pricing', access_field: 'retail_price', group: 'min', format: 'currency'
    rollup 'max_price', access_type: 'pricing', access_field: 'retail_price', group: 'max', format: 'currency'
    rollup 'min_price_cents', access_type: 'pricing', access_field: 'retail_price', group: 'min',
                              format: 'currency_cents'
    rollup 'max_price_cents', access_type: 'pricing', access_field: 'retail_price', group: 'max',
                              format: 'currency_cents'
    rollup 'min_margin_amount', access_type: 'pricing', access_field: 'margin_amount', group: 'min'
    rollup 'max_margin_amount', access_type: 'pricing', access_field: 'margin_amount', group: 'max'
    rollup 'min_margin_amount_cents', access_type: 'pricing', access_field: 'margin_amount', group: 'min',
                                      format: 'currency_cents'
    rollup 'max_margin_amount_cents', access_type: 'pricing', access_field: 'margin_amount', group: 'max',
                                      format: 'currency_cents'
    rollup 'pre_markdown_price', access_type: 'pricing', access_field: 'pre_markdown_price', group: 'max'
    rollup 'pre_markdown_price_cents', access_type: 'pricing', access_field: 'pre_markdown_price', group: 'max',
                                       format: 'currency_cents'

    rollup 'concept_id', access_type: 'service', access_field: 'concept_id'
    rollup 'exclusivity_tier', access_type: 'service', access_field: 'exclusivity_tier'
    rollup 'limited_qty', access_type: 'service', access_field: 'limited_qty', group: 'first'
    rollup 'min_aad_offset_days', access_type: 'service', access_field: 'aad_min_offset_days', group: 'min'
    rollup 'max_aad_offset_days', access_type: 'service', access_field: 'aad_max_offset_days', group: 'max'
    rollup 'on_order_qty', access_type: 'service', access_field: 'on_order_qty', group: 'max'
    rollup 'shipping_method', access_type: 'service', access_field: 'shipping_method'
    rollup 'store_avail_qty', access_type: 'service', access_field: 'stores_avail_qty', group: 'max'
    rollup 'total_avail_qty', access_type: 'service', access_field: 'total_avail_qty', group: 'max'
    rollup 'vdc_avail_qty', access_type: 'service', access_field: 'vdc_avail_qty', group: 'max'
    rollup 'vendor_sku', access_type: 'service', access_field: 'vendor_sku', group: 'max'
    rollup 'warehouse_avail_qty', access_type: 'service', access_field: 'warehouse_avail_qty', group: 'max'

    def id
      "S#{sku_id}"
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

    def brand_code
      CatModels::BrandCache.for_id(brand_id)&.map(&:brand_code)
    end

    def dimensions
      service.concept_skus_iterator_uniq(&:dimensions) || []
    end

    def inventory?
      total_avail_qty > 0
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
        def #{method_name}
          object.send("#{method_name}".to_sym)
        end

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
