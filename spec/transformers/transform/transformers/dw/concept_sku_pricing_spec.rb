require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::DW::ConceptSkuPricing do
  let(:source) { Inbound::DW::ContributionMarginFeed.new }
  let(:target) { CatModels::ConceptSkuPricing.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  describe 'calculate_last_four_weeks' do
    let(:sales_units) { 4 }
    before do
      source.cm_l4w = 44.44
      source.vend_supp_l4w = 88.88
      source.sls_unit_l4w = sales_units
      target.cm_retail_sales_l4w = 12.34
      target.cm_amount_l4w = 16.16 # prior value
      transformer.apply_transformation(target)
    end

    it 'calculates the cm_amount_l4w' do
      expect(target.cm_amount_l4w).to eq 11.11
    end

    it 'calculates the cm_vendor_funded_allowances_l4w' do
      expect(target.cm_vendor_funded_allowances_l4w).to eq 22.22
    end

    it 'clears values when no sum present' do
      expect(target.cm_retail_sales_l4w).to be nil
    end

    context 'when no sales' do
      let(:sales_units) { 0 }
      it('clears values') { expect(target.cm_amount_l4w).to eq nil }
    end

    context 'when negative sales' do
      let(:sales_units) { -2 }
      it('clears values') { expect(target.cm_amount_l4w).to eq nil }
    end
  end
end
