require 'rails_helper'

describe ProductSerializer do
  let(:live_sku) do
    build(:sku).tap do |s|
      s.concept_skus.build(live: true)
    end
  end

  let(:not_live_sku) do
    build(:sku)
  end

  let(:product_single_sku_live) do
    build(:product).tap do |p|
      p.product_memberships.build(sku: live_sku)
    end
  end

  let(:product_single_sku_not_live) do
    build(:product).tap do |p|
      p.product_memberships.build(sku: not_live_sku)
    end
  end

  let(:product_multi_sku) do
    multi_sku_product = build(:product).tap do |p|
      p.product_memberships.build(sku: live_sku)
      p.product_memberships.build(sku: not_live_sku)
    end
    multi_sku_product
  end

  let(:result) { described_class.new(product_model) }

  context 'live rollup' do
    describe 'with single sku live' do
      let(:product_model) { product_single_sku_live }

      it 'should be live if any sku is live' do
        expect(result.live).to eq(true)
      end
    end

    describe 'with single sku not live' do
      let(:product_model) { product_single_sku_not_live }

      it 'should be NOT live' do
        expect(result.live).to eq(false)
      end
    end

    describe 'with a multi sku product' do
      let(:product_model) { product_multi_sku }

      it 'should be live if any sku is live' do
        expect(result.live).to eq(true)
      end
    end
  end
end
