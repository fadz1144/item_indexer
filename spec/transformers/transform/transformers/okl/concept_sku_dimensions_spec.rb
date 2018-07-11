require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptSkuDimensions do
  let(:source) { Inbound::OKL::SkuDimensionsRevision.new.tap(&:build_sku) }
  let(:target) { CatModels::ConceptSkuDimensions.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    context '#item_dimension_display' do
      let(:display) { values['item_dimension_display'] }

      it 'blank when all nil' do
        source.item_length = nil
        source.item_width = nil
        source.item_height = nil
        expect(display).to eq ''
      end

      it 'blank when all zeroes' do
        source.item_length = 0
        source.item_width = 0
        source.item_height = 0
        expect(display).to eq ''
      end

      it 'correct when populated' do
        source.item_length = 1
        source.item_width = 2
        source.item_height = 3
        expect(display).to eq '1" L x 2" W x 3" H'
      end

      it 'includes precision to two places' do
        source.item_length = 1.10
        source.item_width = 2.25
        source.item_height = 3.345
        expect(display).to eq '1.1" L x 2.25" W x 3.35" H'
      end

      it 'leaves out zero dimensions' do
        source.item_length = 1
        source.item_width = 2
        source.item_height = 0
        expect(display).to eq '1" L x 2" W'
      end
    end

    it '#shipping_dimension_display' do
      source.shipping_length = 1
      source.shipping_width = 2
      source.shipping_height = 3
      expect(values['shipping_dimension_display']).to eq '1" L x 2" W x 3" H'
    end

    # required fields at db level
    %w[source_created_by source_created_at source_updated_by source_updated_at].each do |stamp|
      context "##{stamp}" do
        it 'provides default value' do
          expect(values[stamp]).not_to be_nil
        end
      end
    end
  end
end
