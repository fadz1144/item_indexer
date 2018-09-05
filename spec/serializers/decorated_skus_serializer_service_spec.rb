require 'rails_helper'

describe Serializers::DecoratedSkusSerializerService do
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
      p.product_memberships.build(sku: not_live_sku)
      p.product_memberships.build(sku: live_sku)
    end
    multi_sku_product
  end

  let(:service) { described_class.new(Serializers::ProductDecoratorWrapper.new(product)) }

  context '#concept_skus_any?' do
    describe 'with a multi sku product' do
      let(:product) { product_single_sku_live }

      it 'should true if any of the concept skus are true' do
        expect(service.concept_skus_any?(&:live)).to eq(true)
      end
    end

    describe 'with a multi sku product' do
      let(:product) { product_single_sku_not_live }

      it 'should true if any of the concept skus are true' do
        expect(service.concept_skus_any?(&:live)).to eq(false)
      end
    end

    describe 'with a multi sku product' do
      let(:product) { product_multi_sku }

      it 'should true if any of the concept skus are true' do
        expect(service.concept_skus_any?(&:live)).to eq(true)
      end
    end
  end
end
