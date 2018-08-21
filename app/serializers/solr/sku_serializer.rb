## These Serializers are on the way OUT to SOLR
## They are active record model serializers but do so
## in a way thay they can be written to our SOLR index.
module SOLR
  class SkuSerializer < BaseSerializer # rubocop:disable ClassLength
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

    def name
      object.concept_skus&.detect(&:name)&.name
    end

    def description
      service.concept_skus_iterator_uniq(&:description)
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

    def store_avail_qty
      service.field_unique_values(:stores_avail_qty).max
    end

    def vdc_avail_qty
      service.field_unique_values(:vdc_avail_qty).max
    end

    def warehouse_avail_qty
      service.field_unique_values(:warehouse_avail_qty).max
    end

    def on_order_qty
      service.field_unique_values(:on_order_qty).max
    end

    def limited_qty
      service.field_unique_values(:limited_qty).first
    end

    def total_avail_qty
      service.field_unique_values(:total_avail_qty).max
    end

    def vendor_sku
      service.field_unique_values(:vendor_sku).max
    end

    def external_image_url
      object.concept_skus&.detect(&:primary_image)&.primary_image
    end

    def concept_id
      service.field_unique_values(:concept_id)
    end

    def min_price
      as_currency(service.sku_pricing_field_values(:retail_price).min)
    end

    def max_price
      as_currency(service.sku_pricing_field_values(:retail_price).max)
    end

    def min_margin_amount
      service.sku_pricing_field_values(:margin_amount).min
    end

    def max_margin_amount
      service.sku_pricing_field_values(:margin_amount).max
    end

    def min_price_cents
      as_currency_cents(service.sku_pricing_field_values(:retail_price).min)
    end

    def max_price_cents
      as_currency_cents(service.sku_pricing_field_values(:retail_price).max)
    end

    def min_margin_amount_cents
      as_currency_cents(service.sku_pricing_field_values(:margin_amount).min)
    end

    def max_margin_amount_cents
      as_currency_cents(service.sku_pricing_field_values(:margin_amount).max)
    end

    def min_aad_offset_days
      service.field_unique_values(:aad_min_offset_days).min
    end

    def max_aad_offset_days
      service.field_unique_values(:aad_max_offset_days).max
    end

    def cost
      service.sku_pricing_field_values(:cost).max
    end

    def pre_markdown_price
      service.sku_pricing_field_values(:pre_markdown_price).max
    end

    def cost_cents
      as_currency_cents(service.sku_pricing_field_values(:cost).max)
    end

    def pre_markdown_price_cents
      as_currency_cents(service.sku_pricing_field_values(:pre_markdown_price).max)
    end

    def margin_percent
      service.sku_pricing_field_values(:margin_percent).max
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

    def brand_id
      service.concept_skus_iterator_uniq(&:concept_brand_id)
    end

    def brand_name
      service.concept_skus_iterator_uniq(&:display_brand)
    end

    def brand_code
      CatModels::BrandCache.for_id(brand_id)&.map(&:brand_code)
    end

    def vendor_id
      service.concept_skus_iterator_uniq(&:concept_vendor_id)
    end

    def vendor_name
      service.concept_skus_iterator_uniq(&:concept_vendor_name).uniq
    end

    def dimensions
      service.concept_skus_iterator_uniq(&:dimensions) || []
    end

    def inventory?
      total_avail_qty > 0
    end

    def live
      service.concept_skus_any?(&:live)
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

    def exclusivity_tier
      service.field_unique_values(:exclusivity_tier)
    end

    def shipping_method
      service.field_unique_values(:shipping_method)
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

    def as_currency(value, type: 'USD')
      "#{value},#{type}"
    end

    def as_currency_cents(value)
      return 0 unless value
      (value * 100.0).to_i
    end
  end
end
