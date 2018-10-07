require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::Product, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:concept_vendor) { CatModels::ConceptVendor.new(concept_id: 99) }
  let(:source) do
    External::XPDM::Product.new.tap do |product|
      %w[BBBY BABY].each do |code|
        state = External::XPDM::State.new(web_site_cd: code)
        product.concept_products << External::XPDM::ConceptProduct.new(product, state, description: nil)
      end
      product.build_item_vendor(concept_vendor: concept_vendor)
      product.build_concept_brand(concept_id: 99, brand: CatModels::Brand.new)
    end
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::Product.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'
end
