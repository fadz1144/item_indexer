require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::Sku do
  let(:source) { Inbound::OKL::SkuRevision.new }
  let(:target) { CatModels::Sku.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'maps upc to gtin' do
      source.upc = 123
      expect(values['gtin']).to eq 123
    end

    context '#image_count' do
      let(:image_count) { values['image_count'] }

      it 'returns zero with no images' do
        expect(image_count).to eq 0
      end

      it 'returns two with two images' do
        source.images.build
        source.images.build
        expect(image_count).to eq 2
      end
    end
  end
end
