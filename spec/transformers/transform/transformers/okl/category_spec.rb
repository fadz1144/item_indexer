require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::Category do
  let(:source) { Inbound::OKL::CategoryRevision.new.tap { |c| c.source_category_id = 412_345 } }
  let(:transformer) { described_class.new(source) }

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'does not error' do
      expect { values }.not_to raise_exception
    end

    context 'level' do
      let(:level) { values['level'] }

      it 'returns 3 for 412345' do
        expect(level).to eq 3
      end

      it 'returns 2 for 412300' do
        source.source_category_id = 412_300
        expect(level).to eq 2
      end

      it 'returns 1 for 410000' do
        source.source_category_id = 410_000
        expect(level).to eq 1
      end
    end

    it '#parent_id' do
      source.parent_concept_category = CatModels::ConceptCategory.new(category_id: 123)
      expect(values['parent_id']).to eq 123
    end
  end
end
