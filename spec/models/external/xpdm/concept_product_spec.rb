require 'rails_helper'

RSpec.describe External::XPDM::ConceptProduct, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:product) { External::XPDM::Product.new }
  let(:state) { External::XPDM::State.new }
  let(:description) { External::XPDM::Description.new }
  let(:concept_product) { described_class.new(product, state, description: description) }

  context '#concept_id' do
    it 'maps BBBY to 1' do
      state.web_site_cd = 'BBBY'
      expect(concept_product.concept_id).to eq 1
    end

    it 'maps CA to 2' do
      state.web_site_cd = 'CA'
      expect(concept_product.concept_id).to eq 2
    end

    it 'maps BABY to 4' do
      state.web_site_cd = 'CA'
      expect(concept_product.concept_id).to eq 2
    end

    it 'raises error for invalid value' do
      state.web_site_cd = 'OKL'
      expect { concept_product.concept_id }.to raise_error('Invalid web_site_cd: OKL')
    end
  end

  context '#pdp_url' do
    before do
      product.pdm_object_id = 123_456
      description.mstr_prod_desc = 'Roll on you Bears'
    end

    it 'for BBBY' do
      state.web_site_cd = 'BBBY'
      expect(concept_product.pdp_url).to eq 'www.bedbathandbeyond.com/store/product/roll-on-you-bears/123456'
    end

    it 'for CA' do
      state.web_site_cd = 'CA'
      expect(concept_product.pdp_url).to eq 'www.bedbathandbeyond.ca/store/product/roll-on-you-bears/123456'
    end

    it 'for BABY' do
      state.web_site_cd = 'BABY'
      expect(concept_product.pdp_url).to eq 'www.buybuybaby.com/store/product/roll-on-you-bears/123456'
    end

    it 'uses pc as default when no name present' do
      description.mstr_prod_desc = nil
      state.web_site_cd = 'BBBY'
      expect(concept_product.pdp_url).to eq 'www.bedbathandbeyond.com/store/product/pc/123456'
    end
  end

  it '#site_nav_tree_node' do
    state.web_site_cd = 'BBBY'
    expect(product).to receive(:bbby_site_navigation)
    concept_product.site_nav_tree_node
  end
end
