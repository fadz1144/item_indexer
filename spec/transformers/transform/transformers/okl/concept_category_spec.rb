require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptCategory do
  let(:source) { Inbound::OKL::CategoryRevision.new.tap { |c| c.source_category_id = 412_345 } }
  let(:target) { described_class.target_class.new }
  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it '#parent_id' do
      source.parent_concept_category = CatModels::ConceptCategory.new(concept_category_id: 123)
      expect(values['parent_id']).to eq 123
    end

    context '#active' do
      let(:active) { values['active'] }
      it 'returns true when status = ACTIVE' do
        source.status = 'ACTIVE'
        expect(active).to be_truthy
      end

      it 'returns false when status <> ACTIVE' do
        source.status = 'DEFINITELY NOT ACTIVE, WHY DO YOU ASK?'
        expect(active).to be_falsey
      end
    end
  end
end
