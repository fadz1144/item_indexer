require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::Sku, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:concept_vendor) { CatModels::ConceptVendor.new(concept_id: 99) }
  let(:source) do
    External::XPDM::Sku.new.tap do |sku|
      sku.build_concept_brand(concept_id: 99, brand: CatModels::Brand.new)
      sku.descriptions.build(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'ALL')
      sku.descriptions.build(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'USA',
                             jda_desc: 'Blue', pos_desc: 'Gold')
      %w[BBBY BABY CA].each do |code|
        sku.states.build(web_site_cd: code)
        sku.web_prices.build(web_site_cd: code)
      end
      sku.build_item_vendor(concept_vendor: concept_vendor)
      allow(sku).to receive(:item_picture).and_return(double('item_picture', zoom_indexes: '1,2'))
    end
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::Sku.new }
  before do
    allow(Transform::ConceptCache).to receive(:fetch) do |concept_id|
      { 1 => CatModels::Concept.new(concept_id: 1),
        2 => CatModels::Concept.new(concept_id: 2),
        4 => CatModels::Concept.new(concept_id: 4) }.fetch(concept_id)
    end
  end

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'maps prmry_upc_num to gtin' do
      source.prmry_upc_num = 123
      expect(values['gtin']).to eq 123
    end

    it 'uses pdm_object_id as sku_id' do
      source.pdm_object_id = 123
      expect(values['sku_id']).to eq 123
    end

    it('jda_description') { expect(values['jda_description']).to eq 'Blue' }
    it('pos_description') { expect(values['pos_description']).to eq 'Gold' }

    context 'canada compliance info' do
      before do
        source.build_compliance(avail_for_dstrbn_ca_cd: '778', transfrbl_to_ca_ind: 'Y',
                                ec_fulfil_rule_ca_cd: 'E', ec_fulfil_rule_ca_name: 'Standard ECOM Processing')
      end

      it('available_in_ca_dist_cd') { expect(values['available_in_ca_dist_cd']).to eq '778' }
      it('transferable_to_canada') { expect(values['transferable_to_canada']).to be true }
      it('ca_fulfillment_cd') { expect(values['ca_fulfillment_cd']).to eq 'E' }
      it('ca_fulfillment_name') { expect(values['ca_fulfillment_name']).to eq 'Standard ECOM Processing' }
    end
  end

  context 'with two products' do
    let(:site_navigation_node) { CatModels::TreeNode.new }
    before do
      bbby_site_navigation = External::XPDM::BBBYSiteNavigation.new(site_nav_tree_node: site_navigation_node)
      source.product_memberships
            .build(product: External::XPDM::Product.new,
                   concept_product: CatModels::ConceptProduct.new(product: CatModels::Product.new(product_id: 123)))
      source.product_memberships
            .build(product: External::XPDM::Product.new(bbby_site_navigation: bbby_site_navigation),
                   concept_product: CatModels::ConceptProduct.new(product: CatModels::Product.new(product_id: 456)))
      transformer.apply_transformation(target)
    end

    it 'builds two product memberships' do
      expect(target.product_memberships.map(&:product_id)).to contain_exactly(123, 456)
    end

    it 'populates the bbby site navigation' do
      bbby = target.concept_skus.find { |cs| cs.concept_id == 1 }
      expect(bbby.site_nav_tree_node).to be site_navigation_node
    end
  end

  context 'concept skus' do
    before { transformer.apply_transformation(target) }

    it 'creates three concept skus' do
      expect(target.concept_skus.size).to eq 3
    end
  end

  context 'images' do
    before do
      source.image_relation =
        External::XPDM::ImageRelation.new(item_code_name_cd: 'IMG_123', item_code_name: 'oski.jpg')
      transformer.apply_transformation(target)
    end

    it 'generates three concept sku images' do
      expect(target.concept_skus.first.concept_sku_images.size).to eq 3
    end
  end

  context 'no brand assigned' do
    let(:concept_brand) { CatModels::ConceptBrand.new(concept_id: 99) }
    let(:no_brand_assigned) { CatModels::Brand.new.tap { |b| b.concept_brands << concept_brand } }
    before do
      source.concept_brand = nil
      allow(External::MissingBrandService).to receive(:no_brand_assigned).and_return(no_brand_assigned)
      transformer.apply_transformation(target)
    end

    it 'assigns dummy brand' do
      expect(target.brand).to be no_brand_assigned
    end

    it 'assigns dummy concept brand' do
      expect(target.concept_skus.all? { |cs| cs.concept_brand == concept_brand }).to be true
    end
  end
end
