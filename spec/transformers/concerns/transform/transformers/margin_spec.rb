require 'rails_helper'

RSpec.describe Transform::Transformers::Margin do
  shared_examples 'margin not calculated' do
    it 'margin_amount is nil' do
      expect(model.margin_amount).to be_nil
    end

    it 'margin_percent is nil' do
      expect(model.margin_percent).to be_nil
    end
  end

  context 'price is zero' do
    let(:model) { double('ConceptSku', price: 0, cost: 123.45).extend(described_class) }
    it_behaves_like 'margin not calculated'
  end

  context 'price is nil' do
    let(:model) { double('ConceptSku', price: nil, cost: 123.45).extend(described_class) }
    it_behaves_like 'margin not calculated'
  end

  context 'cost is zero' do
    let(:model) { double('ConceptSku', price: 123.45, cost: 0).extend(described_class) }
    it_behaves_like 'margin not calculated'
  end

  context 'cost is nil' do
    let(:model) { double('ConceptSku', price: 123.45, cost: nil).extend(described_class) }
    it_behaves_like 'margin not calculated'
  end
end
