require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::ConceptSkuImage do
  let(:source) do
    Inbound::OKL::SkuImageRevision.new
  end

  let(:transformer) { described_class.new(source) }

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'does not error' do
      expect { values }.not_to raise_exception
    end

    it '#image_url' do
      source.resource_folder = 'go'
      source.resource_name = 'bears'
      expect(values['image_url']).to eq 'https://okl.scene7.com/is/image/go/bears'
    end
  end
end
