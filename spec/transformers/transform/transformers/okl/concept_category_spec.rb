require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::ConceptCategory do
  let(:source) { Inbound::OKL::CategoryRevision.new.tap { |c| c.source_category_id = 412_345 } }
  let(:target) { described_class.target_class.new }
  let(:transformer) { described_class.new(source) }

  it 'source_class is valid' do
    expect { described_class.source_class }.not_to raise_error
  end

  it 'target_class is valid' do
    expect { described_class.target_class }.not_to raise_error
  end

  context '#apply_transformation' do
    let(:results) do
      transformer.apply_transformation(target)
      target
    end

    it 'does not error' do
      expect { results }.not_to raise_exception
    end
  end

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }
    it 'does not error' do
      expect { values }.not_to raise_exception
    end

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
