require 'rails_helper'

describe Serializers::DecoratedSkusSerializerService do
  let(:service) { described_class.new(product) }

  # TODO: REPLACE WITH FACTORY GIRL
  # Pulled from sku_serializer_spec

  let(:product) do
    product_model.skus << sku_model
    product_model.skus << sku_model2
    product_model
  end

  # TODO: replace with FactoryGirl?
  let(:brand_model) do
    CatModels::Brand.new(
      id: 100,
      name: 'Bodhi'
    )
  end
  let(:category_model) do
    CatModels::Category.new(
      category_id: 450_000,
      parent_id: nil,
      name: 'Televisions',
      level: 1
    )
  end

  let(:product_model) do
    p = CatModels::Product.new(
      product_id: 1_234_567,
      category_id: category_model.category_id
    )
    p.concept_products = [concept_product_model]
    p
  end

  let(:concept_product_model) do
    CatModels::ConceptProduct.new(
      product_id: 1_234_567,
      active: true,
      status: 'ACTIVE',
      name: 'Some Product Name',
      description: 'Some Product Description',
      pdp_url: 'https://some.pdp.url/'
    )
  end

  let(:concept_sku_image_model) do
    CatModels::ConceptSkuImage.new(
      image_url: 'https://okl.scene7.com/is/image/OKL/Product_Some_Image_',
      primary_sku_image: true
    )
  end

  let(:concept_sku_dimensions_model) do
    CatModels::ConceptSkuDimensions.new
  end

  let(:concept_vendor_model) do
    CatModels::ConceptVendor.new
  end

  # rubocop:disable Metrics/BlockLength
  let(:concept_sku_model) do
    cs = CatModels::ConceptSku.new(
      vendor_sku: 'ABC12345',
      active: true,
      status: 'ACTIVE',
      name: 'Some Sku Name',
      description: 'Some Sku Description',
      color: 'red/white/blue',
      era: nil,
      style: 'traditional',
      materials: 'wool',
      care_instructions: nil,
      lead_time: 12,
      aad_min_offset_days: 6,
      aad_max_offset_days: 9,
      ltl_eligible: false,
      threshold_eligible: false,
      shipping_method: 'Standard',
      total_avail_qty: 50,
      warehouse_avail_qty: 2,
      vdc_avail_qty: 57,
      on_order_qty: 3,
      limited_qty: false,
      live: true,
      allow_exposure: true,
      exclusivity_tier: 'Not Exclusive'
    )
    cs.concept_sku_images = [concept_sku_image_model]
    cs.concept_sku_dimensions = concept_sku_dimensions_model
    cs.concept_vendor = concept_vendor_model
    cs.extend(CatModels::ConceptSkuDecorator)
    cs
  end
  # rubocop:enable all

  # rubocop:disable Metrics/BlockLength
  let(:concept_sku_model2) do
    cs = CatModels::ConceptSku.new(
      vendor_sku: 'ABC12346',
      active: true,
      status: 'ACTIVE',
      name: 'Some Sku Name',
      description: 'Some Sku Description',
      color: 'red/white/blue',
      era: nil,
      style: 'traditional',
      materials: 'wool',
      care_instructions: nil,
      lead_time: 14,
      aad_min_offset_days: 6,
      aad_max_offset_days: 10,
      ltl_eligible: false,
      threshold_eligible: false,
      shipping_method: 'Standard',
      total_avail_qty: 40,
      warehouse_avail_qty: 2,
      vdc_avail_qty: 57,
      on_order_qty: 3,
      limited_qty: false,
      live: true,
      allow_exposure: true,
      exclusivity_tier: 'Not Exclusive'
    )
    cs.concept_sku_images = [concept_sku_image_model]
    cs.concept_sku_dimensions = concept_sku_dimensions_model
    cs.concept_vendor = concept_vendor_model
    cs.extend(CatModels::ConceptSkuDecorator)
    cs
  end
  # rubocop:enable all

  let(:sku_model) do
    sku = CatModels::Sku.new(
      sku_id: 99_999,
      gtin: 749_151_007_215,
      brand_id: 34_197,
      category_id: 450_000,
      unit_of_measure_cd: 'EA',
      vmf: false,
      color_family: 'white',
      non_taxable: false,
      vintage: false,
      image_count: 1
    )
    sku.category = category_model
    sku.brand = brand_model
    sku.concept_skus = [concept_sku_model]
    sku.products = [product_model]
    sku.extend(CatModels::SkuDecorator)
    sku
  end

  let(:sku_model2) do
    sku = CatModels::Sku.new(
      sku_id: 99_998,
      gtin: 749_151_007_214,
      brand_id: 34_197,
      category_id: 450_000,
      unit_of_measure_cd: 'EA',
      vmf: false,
      color_family: 'white',
      non_taxable: false,
      vintage: false,
      image_count: 1
    )
    sku.category = category_model
    sku.brand = brand_model
    sku.concept_skus = [concept_sku_model2]
    sku.products = [product_model]
    sku.extend(CatModels::SkuDecorator)
    sku
  end

  it 'should raise if nill passed to constructor' do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  it 'supports field_values' do
    expect(service.field_values(:aad_min_offset_days)).to eq([6, 6])
  end

  it 'supports field_values' do
    expect(service.field_unique_values(:aad_min_offset_days)).to eq([6])
  end
end
