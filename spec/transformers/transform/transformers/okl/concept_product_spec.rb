require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::ConceptProduct do
  let(:source) { Inbound::OKL::ProductRevision.new }
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

    it 'truncates description' do
      source.description = 'roll on you bears ' * 60
      expect(values['description'].length).to eq 1_000
    end

    it 'returns a date when none present' do
      expect(values['source_created_at']).to be_present
    end

    it 'does not override supplied date' do
      source.source_created_at = Time.current.yesterday.beginning_of_day
      expect(values['source_created_at']).to eq source.source_created_at
    end
  end

  context 'black magic' do # see Inbound::CommonConceptForeignKeys
    before do
      CatModels::Concept.create(concept_id: 3, name: 'One Kings Lane', abbreviation: 'OKL',
                                legal_name: 'Barry Zuckercorn')
      Inbound::OKL::ProductRevision.create(source_product_id: 123,
                                           inbound_batch: Inbound::Batch.create(source: 'okl', data_type: 'product'))
    end

    it 'loads product revision with pseudo-association concept' do
      expect { Inbound::OKL::ProductRevision.includes(:concept).first }.not_to raise_exception
    end
  end
end
