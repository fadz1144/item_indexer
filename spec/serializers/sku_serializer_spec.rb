require 'rails_helper'

RSpec.describe SkuSerializer do
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

  let(:sku_model) do
    # :sku_id, :gtin, :product_id, :product_name, :upc_ean, :name, :category, :inventory, :pricing, :vendor,
    #   :active, :allow_exposure, :non_taxable, :unit_of_measure, :vmf, :vintage, :color, :description,
    #   :internal_color_family, :external_image_url, :sku_status_has_inv, :sku_status_live, :brand, :dimensions,
    #   :lead_time, :aad_min_offset_days, :aad_max_offset_days, :shipping_method

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
  let(:serializer) { described_class.new(sku_model) }

  subject { JSON.parse(serializer.to_json) }

  before(:each) do
    allow(CatModels::CategoryCache).to receive(:hierarchy_for).and_return([category_model])
  end

  context 'sku_model fields' do
    %w[sku_id gtin vmf vintage non_taxable].each do |field|
      it "should have #{field} that matches" do
        expect(subject[field]).to eql(sku_model.send(field.to_sym))
      end
    end
  end

  context 'concept_sku_model fields' do
    # primitive fieldss
    %w[name active allow_exposure lead_time aad_min_offset_days aad_max_offset_days].each do |field|
      it "should have #{field} that matches" do
        expect(subject[field]).to eql(concept_sku_model.send(field.to_sym))
      end
    end

    # array fields
    %w[description shipping_method].each do |field|
      it "should have #{field} that matches" do
        arr = [concept_sku_model.send(field.to_sym)]
        expect(subject[field]).to eql(arr)
      end
    end
  end

  it 'should have a vintage that matches' do
    expect(subject['color']).to eql(sku_model.color_family)
  end

  it 'should have a unit_of_measure that matches' do
    expect(subject['unit_of_measure']).to eql(sku_model.unit_of_measure_cd)
  end

  it 'should have a product_id that matches' do
    expect(subject['product_id']).to eql([product_model.product_id])
  end

  it 'should have a product_name that matches' do
    expect(subject['product_name']).to eql([concept_product_model.name])
  end

  it 'should have a upc_ean that matches' do
    expect(subject['upc_ean']).to eql(concept_sku_model.gtin)
  end

  it 'should have a internal_color_family that matches' do
    expect(subject['internal_color_family']).to eql([concept_sku_model.color])
  end

  it 'should have a external_image_url that matches' do
    expect(subject['external_image_url']).to eql(concept_sku_model.primary_image)
  end

  it 'should have a sku_status_has_inv that matches' do
    expect(subject['sku_status_has_inv']).to be_truthy
  end

  it 'should have a sku_status_live that matches' do
    expect(subject['sku_status_live']).to be_truthy
  end

  # TODO: handle embedded objects
  %w[category inventory pricing vendor brand dimensions].each do |f|
    xit "It should have a match for #{f}"
  end
end
