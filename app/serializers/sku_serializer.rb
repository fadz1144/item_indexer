class SkuSerializer < ActiveModel::Serializer
  attributes :sku_id, :gtin, :product_id, :product_name, :upc_ean, :name,
             :category, :inventory, :pricing, :vendor,
             :active, :allow_exposure, :non_taxable, :unit_of_measure, :vmf, :vintage,
             :color, :description, :internal_color_family, :external_image_url,
             :sku_status_has_inv, :sku_status_live, :brand, :dimensions

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
      p&.concept_products&.each_with_object(agg) { |cp, agg| agg << cp.name }
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

  #    vendor: [
  #    {
  #      site_id: 1,
  #      id: s.vendor_id,
  #      vendor_sku: s.vendor_sku,
  #      name: s.vendor&.name
  #    }
  #  ]
  #  }
  def vendor
    # TODO: vendor
    {}
  end

  # TODO: Not sure about the names for these flags
  def sku_status_live
    object.concept_skus.any?(&:live)
  end

  def sku_status_has_inv
    object.concept_skus.any? { |cs| cs.total_avail_qty > 0 }
  end

  private

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
