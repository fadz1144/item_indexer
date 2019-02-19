require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::JDA::ConceptSkuPricing do
  let(:source) { Inbound::JDA::PricingChange.new }
  let(:target) { CatModels::ConceptSkuPricing.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  describe '#calculate_margin' do
    shared_examples 'no margin calculated' do
      before { transformer.apply_transformation(target) }
      it { expect(target.margin_amount).to be_nil }
      it { expect(target.margin_percent).to be_nil }
    end

    context 'with no cost' do
      context('and no price') { it_behaves_like 'no margin calculated' }

      context 'and price present' do
        before { source.AUREGU = 12.34 }
        it_behaves_like 'no margin calculated'
      end
    end

    context 'with cost same as price' do
      before do
        target.cost = 12.34
        source.AUREGU = 12.34
      end

      it_behaves_like 'no margin calculated'
    end

    context 'with price greater than cost' do
      before do
        target.cost = 5
        source.AUREGU = 10
        transformer.apply_transformation(target)
      end

      it 'calculates margin_amount' do
        expect(target.margin_amount).to eql 5
      end

      it 'calculates margin_percent' do
        expect(target.margin_percent).to eq 0.5
      end
    end
  end
end
