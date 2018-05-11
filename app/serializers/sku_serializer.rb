class SkuSerializer < ActiveModel::Serializer
  attributes :sku_id, :gtin, :product_id, :product_name, :upc_ean, :name, :category, :inventory, :pricing, :vendor,
             :active, :allow_exposure, :non_taxable, :unit_of_measure, :vmf, :vintage, :color, :description,
             :internal_color_family, :external_image_url, :sku_status_has_inv, :sku_status_live, :brand, :dimensions,
             :lead_time, :aad_min_offset_days, :aad_max_offset_days, :shipping_method,
             :exclusivity_tier, :item_status

  # NOT MIGRATED
  #    content_ready: s.sku_states.content_ready,
  #    copy_ready: s.sku_states.copy_ready,
  #    customer_set_quantity: s.customer_set_quantity,
  #    deleted: s.is_deleted,
  #    exclusivity_tier: s.sku_states.exclusivity_tier,
  #    inactive_reason_id: s.sku_states.inactive_reason_id,
  #    line_of_business_id: s.line_of_business_id,

  def external_image_url
    object.concept_skus&.detect(&:primary_image)&.primary_image
  end

  def product_id
    object.products&.map(&:product_id)
  end

  def product_name
    object.products&.each_with_object([]) do |p, agg|
      p&.concept_products&.each_with_object(agg) { |cp, arr| arr << cp.name }
    end
  end

  def upc_ean
    object.gtin
  end

  def name
    object.concept_skus&.detect(&:name)&.name
  end

  def active
    active?
  end

  def allow_exposure
    allow_exposure?
  end

  def unit_of_measure
    object.unit_of_measure_cd
  end

  def color
    object.color_family
  end

  def description
    object.concept_skus&.map(&:description) || []
  end

  def dimensions
    object.concept_skus&.map(&:dimensions) || []
  end

  def internal_color_family
    object.concept_skus&.map(&:color) || []
  end

  def brand
    BrandSerializer.new(object.brand).as_json if object.brand
  end

  #    category: categories_for_sku(s),
  def category
    hierarchy = CatModels::CategoryCache.hierarchy_for(object.category&.category_id)
    hierarchy&.map { |c| c.as_json } || []
  end

  def inventory
    object.concept_skus&.map { |concept_sku| inventory_for_concept_sku(concept_sku) }
  end

  def inventory_for_concept_sku(concept_sku)
    {
      concept_id:          concept_sku.concept_id,
      store_avail_qty:     concept_sku.stores_avail_qty,
      vdc_avail_qty:       concept_sku.vdc_avail_qty,
      warehouse_avail_qty: concept_sku.warehouse_avail_qty,
      on_order_qty:        concept_sku.on_order_qty,
      limited_qty:         concept_sku.limited_qty,
      total_avail_qty:     concept_sku.total_avail_qty
    }
  end

  def pricing
    object.concept_skus&.each_with_object([]) do |concept_sku, acc|
      pricing = concept_sku.concept_sku_pricing
      acc << pricing_for_concept_sku(pricing) if pricing.present?
    end
  end

  def vendor
    object.concept_skus&.map { |concept_sku| vendor_for_concept_sku(concept_sku) }
  end

  # TODO: Not sure about the names for these flags
  def sku_status_live
    object.concept_skus.any?(&:live)
  end

  def sku_status_has_inv
    object.concept_skus.any? { |cs| cs.total_avail_qty > 0 }
  end

  def lead_time
    object.concept_skus&.map(&:lead_time)&.min
  end

  def aad_min_offset_days
    object.concept_skus&.map(&:aad_min_offset_days)&.min
  end

  def aad_max_offset_days
    object.concept_skus&.map(&:aad_max_offset_days)&.max
  end

  def shipping_method
    object.concept_skus&.map(&:shipping_method)&.uniq
  end

  def exclusivity_tier
    object.concept_skus.map(&:exclusivity_tier)&.uniq
  end

  def item_status
    result = object.concept_skus.map(&:status) + object.concept_skus.map(&:suspended_reason)
    result.flatten.uniq
  end

  private

  def vendor_for_concept_sku(concept_sku)
    vendor = {}
    vendor[:id] = concept_sku.concept_vendor_id if concept_sku.concept_vendor_id
    vendor[:concept_id] = concept_sku.concept_id if concept_sku.concept_id
    vendor[:vendor_sku] = concept_sku.vendor_sku if concept_sku.vendor_sku
    vendor[:name] = concept_sku.concept_vendor.name if concept_sku.concept_vendor&.name
    vendor
  end

  # TODO: might want sku_pricing_serializer?
  def pricing_for_concept_sku(pricing)
    {
      concept_id: pricing.concept_id,
      min_price: pricing.retail_price,
      max_price: pricing.retail_price,
      cost: pricing.cost,
      pre_markdown_price: pricing.pre_markdown_price,
      margin_amount: pricing.margin_amount,
      margin_percent: pricing.margin_percent
    }
  end

  def active?
    object.concept_skus.any?(&:active?)
  end

  def allow_exposure?
    object.concept_skus.any?(&:allow_exposure?)
  end
end
