require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::ConceptBrand,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  before do
    allow(described_class).to receive(:concept).and_return(concept)
    allow(described_class).to receive(:brand_cache).and_return(brand_cache)
  end
  let(:concept) { CatModels::Concept.new }
  let(:brand) { CatModels::Brand.new }
  let(:brand_cache) { { 'oski' => brand } }

  let(:source) do
    External::XPDM::Brand.new(brand_name: 'oski')
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::ConceptBrand.new }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'name' do
      expect(values['name']).to eql 'oski'
    end

    it 'concept' do
      expect(values['concept']).to be concept
    end

    it 'brand' do
      expect(values['brand']).to be brand
    end
  end
end
