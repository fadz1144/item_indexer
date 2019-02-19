require 'rails_helper'

RSpec.describe Transform::Transformers::MarginCalculator do
  let(:pricing) do
    CatModels::ConceptSkuPricing.new.tap do |csp|
      allow(csp).to receive(:margin_determinable?).and_return(margin_determinable)
    end
  end
  let(:transformer) { instance_double('transformer').extend(described_class) }

  context 'when margin determinable' do
    let(:margin_determinable) { true }
    before do
      pricing.retail_price = 22
      pricing.cost = 11
      transformer.calculate_margin(pricing)
    end

    it 'calculates amount' do
      expect(pricing.margin_amount).to eq 11
    end

    it 'calculates percent' do
      expect(pricing.margin_percent).to eq 0.5
    end
  end

  context 'when margin not determinable' do
    let(:margin_determinable) { false }
    before do
      pricing.margin_amount = 10
      pricing.margin_percent = 0.2
      transformer.calculate_margin(pricing)
    end

    it 'removes amount' do
      expect(pricing.margin_amount).to be_nil
    end

    it 'removes percent' do
      expect(pricing.margin_percent).to be_nil
    end
  end
end
