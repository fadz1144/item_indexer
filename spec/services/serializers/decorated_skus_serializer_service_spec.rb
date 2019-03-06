require 'rails_helper'

describe Serializers::DecoratedSkusSerializerService do
  let(:service) { described_class.new(Serializers::ProductDecoratorWrapper.new(product)) }

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

  let(:site_navigation_model) do
    CatModels::SiteNavigation.new(
      leaf_tree_node_id: 333
    )
  end

  let(:concept_product_model) do
    CatModels::ConceptProduct.new(
      product_id: 1_234_567,
      active: true,
      status: 'ACTIVE',
      name: 'Some Product Name',
      description: 'Some Product Description',
      pdp_url: 'https://some.pdp.url/',
      site_navigations: [site_navigation_model],
      concept_id: 1
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

  it 'should raise if nil passed to constructor' do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  context '#tree_node_values' do
    before do
      tree_cache = class_double('Indexer::TreeCache').as_stubbed_const(transfer_nested_constants: true)
      tree_cache_entry = [
        { id: 111, source_code: 'AAA' },
        { id: 222, source_code: 'BBB' },
        { id: 333, source_code: 'CCC' }
      ]
      allow(tree_cache).to receive(:fetch).with(333).and_return(tree_cache_entry)
    end

    it 'supports concept product level node ids' do
      expect(service.tree_node_values(:bbby_site_nav, :id)).to eq([111, 222, 333])
    end

    it 'supports concept product level node source codes' do
      expect(service.tree_node_values(:bbby_site_nav, :source_code)).to eq(%w[AAA BBB CCC])
    end
  end

  it 'supports field_unique_values' do
    expect(service.field_unique_values(:aad_min_offset_days)).to eq([6])
  end

  context 'CA cost and price double BBBY' do
    let(:service) do
      sku = CatModels::Sku.new.tap do |s|
        s.concept_skus.build(concept_id: 1).tap { |cs| cs.build_concept_sku_pricing(retail_price: 10, cost: 5) }
        s.concept_skus.build(concept_id: 2).tap { |cs| cs.build_concept_sku_pricing(retail_price: 20, cost: 10) }
        s.concept_skus.build(concept_id: 3).tap { |cs| cs.build_concept_sku_pricing(retail_price: 12, cost: 6) }
      end

      described_class.new(instance_double(Serializers::SkuDecoratorWrapper, decorated_skus: [sku]))
    end

    it 'sku pricing field values for retail price do not include CA' do
      expect(service.sku_pricing_field_values(:retail_price)).to contain_exactly(10, 12)
    end

    it 'sku pricing field values for cost do not include CA' do
      expect(service.sku_pricing_field_values(:cost)).to contain_exactly(5, 6)
    end
  end
end
