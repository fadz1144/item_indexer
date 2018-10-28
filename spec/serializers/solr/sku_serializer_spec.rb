require 'rails_helper'

RSpec.describe SOLR::SkuSerializer do
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

  let(:concept_sku_model) do # rubocop:disable BlockLength
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
  let(:concept_sku_models) { [concept_sku_model] }

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
    sku.concept_skus = concept_sku_models
    sku.products = [product_model]
    sku.extend(CatModels::SkuDecorator)
    sku
  end

  let(:result) { described_class.new(sku_model).as_json }

  before(:each) do
    allow(CatModels::CategoryCache).to receive(:hierarchy_for).and_return([category_model])
  end

  context 'test dynamic serializer' do
    describe 'check if it compiles' do
      it 'should not raise and error' do
        expect { result }.not_to raise_exception
      end
    end
  end

  context 'sku_model fields' do
    %i[sku_id gtin vmf].each do |field|
      it "should have #{field} that matches" do
        expect(result[field]).to eql(sku_model.send(field.to_sym))
      end
    end
  end

  context 'concept_sku_model fields' do
    # primitive fields
    %i[name].each do |field|
      it "should have #{field} that matches" do
        expect(result[field]).to eql(concept_sku_model.send(field.to_sym))
      end
    end

    # TODO: active allow_exposure lead_time aad_min_offset_days aad_max_offset_days ?

    # array fields
    %i[description shipping_method].each do |field|
      it "should have #{field} that matches" do
        arr = [concept_sku_model.send(field.to_sym)]
        expect(result[field]).to eql(arr)
      end
    end
  end

  it 'should have a color that matches' do
    expect(result[:color]).to contain_exactly(sku_model.color_family)
  end

  it 'should have a product_id that matches' do
    expect(result[:product_id]).to contain_exactly(product_model.product_id)
  end

  xit 'should have a product_name that matches' do
    expect(result[:product_name]).to contain_exactly(concept_product_model.name)
  end

  it 'should have a upc_ean that matches' do
    expect(result[:upc_ean]).to eql(concept_sku_model.gtin)
  end

  it 'should have a external_image_url that matches' do
    expect(result[:external_image_url]).to eql(concept_sku_model.primary_image)
  end

  context 'web status' do
    let(:concept_sku_models) do
      [build(:full_concept_sku, concept_id: 1, web_status: CatModels::WebStatus::ACTIVE),
       build(:full_concept_sku, concept_id: 2, web_status: CatModels::WebStatus::BUYER_REVIEWED),
       build(:full_concept_sku, concept_id: 3, web_status: CatModels::WebStatus::IN_PROGRESS),
       build(:full_concept_sku, concept_id: 4, web_status: CatModels::WebStatus::SUSPENDED)]
    end

    it 'should have a web_status' do
      expect(result[:web_status]).to contain_exactly(*concept_sku_models.map(&:web_status))
    end

    it 'should have a web_status_buyer_reviewed' do
      expect(result[:web_status_buyer_reviewed]).to eql(sku_model.web_status_buyer_reviewed)
    end

    it 'should have a web_status_in_progress' do
      expect(result[:web_status_in_progress]).to eql(sku_model.web_status_in_progress)
    end

    it 'should have a web_status_active' do
      expect(result[:web_status_active]).to eql(sku_model.web_status_active)
    end

    it 'should have a web_status_suspended' do
      expect(result[:web_status_suspended]).to eql(sku_model.web_status_suspended)
    end
  end
end
