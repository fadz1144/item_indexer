require 'rails_helper'
require 'support/transformer_examples'
require 'support/shared_examples_for_cm_tags_transformation'
require 'support/shared_examples_for_promo_attributes_transformation'

RSpec.describe Transform::Transformers::XPDM::Collection,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:concept_vendor) { CatModels::ConceptVendor.new(concept_id: 99) }
  let(:source) do
    External::XPDM::Collection.new.tap do |collection|
      %w[BBBY BABY].each do |code|
        state = External::XPDM::State.new(web_site_cd: code)
        collection.concept_collections << External::XPDM::ConceptCollection.new(collection, state, description: nil)
      end
      collection.build_item_vendor(concept_vendor: concept_vendor)
      collection.build_concept_brand(concept_id: 99, brand: CatModels::Brand.new)
    end
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::Collection.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'
  it_behaves_like 'transformation includes tags'
  it_behaves_like 'transformation includes promo attributes'

  context 'with two products' do
    before do
      source.collection_memberships
            .build(product: External::XPDM::Product.new,
                   concept_product: CatModels::ConceptProduct.new(product: CatModels::Product.new(product_id: 123)))
      source.collection_memberships
            .build(product: External::XPDM::Product.new,
                   concept_product: CatModels::ConceptProduct.new(product: CatModels::Product.new(product_id: 456)))
      transformer.apply_transformation(target)
    end

    it 'builds two product memberships' do
      expect(target.collection_memberships.map(&:product_id)).to contain_exactly(123, 456)
    end
  end
end
