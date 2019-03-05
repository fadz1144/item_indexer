require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptSkuPricing do
  let(:source) { Inbound::OKL::SkuRevision.new }
  let(:target) { CatModels::ConceptSkuPricing.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#calculate_margin' do
    context '#margin_amount' do
      let(:margin_amount) do
        transformer.apply_transformation(target)
        target.margin_amount
      end

      it 'without price returns nil' do
        source.cost = 11
        expect(margin_amount).to be_nil
      end

      it 'without cost returns nil' do
        source.price = 22
        expect(margin_amount).to be_nil
      end

      it 'with cost < price returns negative margin' do
        source.cost = 22
        source.price = 11
        expect(margin_amount).to eq(-11)
      end

      it 'with cost == price returns zero' do
        source.cost = 22
        source.price = 22
        expect(margin_amount).to be_zero
      end

      it 'returns diff when price > cost' do
        source.price = 16
        source.cost = 12
        expect(margin_amount).to eq 4
      end
    end

    context '#margin_percent' do
      let(:margin_percent) do
        transformer.apply_transformation(target)
        target.margin_percent
      end

      it 'returns nil when margin_amount nil' do
        expect(margin_percent).to be_nil
      end

      it 'returns percent when price > cost' do
        source.price = 16
        source.cost = 12
        expect(margin_percent).to eq 0.25
      end
    end
  end
end
