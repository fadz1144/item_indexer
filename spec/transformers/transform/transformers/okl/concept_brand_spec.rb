require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::ConceptBrand do
  let(:source) { Inbound::OKL::BrandRevision.new }
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
  end
end
