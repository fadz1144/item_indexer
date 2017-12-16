require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::ConceptSkuPricing do
  let(:source) do
    Inbound::OKL::SkuRevision.new
  end

  let(:transformer) { described_class.new(source) }

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'does not error' do
      expect { values }.not_to raise_exception
    end

    context '#margin_amount' do
      let(:margin_amount) { values['margin_amount'] }
      it 'without price returns nil' do
        source.cost = 11
        expect(margin_amount).to be_nil
      end

      it 'without cost returns nil' do
        source.price = 22
        expect(margin_amount).to be_nil
      end

      it 'with cost < price returns nil' do
        source.cost = 22
        source.price = 11
        expect(margin_amount).to be_nil
      end

      it 'with cost == price returns nil' do
        source.cost = 22
        source.price = 22
        expect(margin_amount).to be_nil
      end

      it 'returns diff when price > cost' do
        source.price = 16
        source.cost = 12
        expect(margin_amount).to eq 4
      end
    end

    context '#margin_percent' do
      let(:margin_percent) { values['margin_percent'] }
      it 'returns nil when margin_amount nil' do
        expect(margin_percent).to be_nil
      end

      it 'returns nil when price zero' do
        source.price = 0
        source.cost = -1
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
