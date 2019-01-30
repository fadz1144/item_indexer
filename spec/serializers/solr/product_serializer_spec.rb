require 'rails_helper'

describe SOLR::ProductSerializer do
  let(:brand_model) do
    CatModels::Brand.new(
      id: 100,
      name: 'Bodhi'
    )
  end

  let(:sku) do
    build(:sku).tap do |s|
      [1, 2, 3, 4].each do |concept_id|
        s.concept_skus.build(concept_id: concept_id, concept_vendor: CatModels::ConceptVendor.new)
      end
    end
  end

  let(:live_sku) do
    build(:sku).tap do |s|
      [1, 2, 3, 4].each do |concept_id|
        s.concept_skus.build(concept_id: concept_id, live: true, concept_vendor: CatModels::ConceptVendor.new)
      end
      s.brand = brand_model
    end
  end

  let(:not_live_sku) do
    build(:sku).tap do |s|
      [1, 2, 3, 4].each do |concept_id|
        s.concept_skus.build(concept_id: concept_id, concept_vendor: CatModels::ConceptVendor.new)
      end
      s.brand = brand_model
    end
  end

  let(:product_single_sku_live) do
    build(:product).tap do |p|
      p.product_memberships.build(sku: live_sku)
    end
  end

  let(:vdc_sku) do
    build(:sku).tap do |s|
      s.vdc_sku = true
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

  let(:result) { ActiveModelSerializers::SerializableResource.new(product_model, serializer: described_class) }

  context 'test dynamic serializer' do
    describe 'check if it compiles' do
      let(:product_model) { product_multi_sku }

      it 'should be live if any sku is live' do
        expect { result.as_json }.not_to raise_exception
      end
    end
  end

  context 'vdc_flag' do
    let(:product_model) { product_multi_sku }

    it 'false when no underlying skus are vdc_sku' do
      expect(result.as_json[:vdc_flag]).to be_falsey
    end

    it 'true when one underlying sku is vdc_sku' do
      product_multi_sku.product_memberships.build(sku: vdc_sku)
      expect(result.as_json[:vdc_flag]).to be_truthy
    end
  end
end
