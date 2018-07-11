require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptSkuImage do
  let(:source) { Inbound::OKL::SkuImageRevision.new }
  let(:target) { CatModels::ConceptSkuImage.new }

  let(:transformer) { described_class.new(source) }
  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it '#image_url' do
      source.resource_folder = 'go'
      source.resource_name = 'bears'
      expect(values['image_url']).to eq 'https://okl.scene7.com/is/image/go/bears'
    end
  end
end
