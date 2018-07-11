require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptSku do
  let(:source) do
    Inbound::OKL::SkuRevision.new.tap do |sku|
      sku.build_shipping
      sku.build_state
      sku.build_dimensions
      sku.build_inventory
      # sku.concept = concept
    end
  end
  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::ConceptSku.new }

  it_behaves_like 'valid transformer'
  context '#apply_transformation' do
    let(:results) do
      transformer.apply_transformation(target)
      target
    end

    context 'with a source image' do
      before { source.images.build(resource_name: 'oski') }

      it 'creates an image' do
        expect(results.concept_sku_images.size).to eq 1
      end

      it 'populates the resource name' do
        expect(results.concept_sku_images.first.resource_name).to eq 'oski'
      end
    end

    context 'with pricing' do
      before do
        source.price = 16
        source.cost = 12
      end

      it 'creates a pricing entry' do
        expect(results.concept_sku_pricing).not_to be_nil
      end

      it 'populates retail price' do
        expect(results.concept_sku_pricing.retail_price).to eq 16
      end

      it 'populates cost' do
        expect(results.concept_sku_pricing.cost).to eq 12
      end
    end

    context 'with dimensions' do
      before do
        source.dimensions.tap do |dim|
          dim.item_length = 1
          dim.item_width = 2
          dim.item_height = 3
        end
      end
      let(:dimensions) { results.concept_sku_dimensions }

      it 'creates a dimensions entry' do
        expect(dimensions).not_to be_nil
      end

      it 'populates item length' do
        expect(dimensions.item_length).to eq 1
      end

      it 'populates item width' do
        expect(dimensions.item_width).to eq 2
      end

      it 'populates item height' do
        expect(dimensions.item_height).to eq 3
      end
    end

    context 'with inventory' do
      before do
        source.inventory.tap do |inv|
          inv.total_avail_qty = 1
          inv.warehouse_avail_qty = 2
          inv.stores_avail_qty = 3
          inv.vdc_avail_qty = 4
        end
      end

      it('#total_avail_qty') { expect(results.total_avail_qty).to eq 1 }
      it('#warehouse_avail_qty') { expect(results.warehouse_avail_qty).to eq 2 }
      it('#stores_avail_qty') { expect(results.stores_avail_qty).to eq 3 }
      it('#vdc_avail_qty') { expect(results.vdc_avail_qty).to eq 4 }
    end
  end

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }
    context '#status' do
      it 'active and not obsolete returns Active' do
        source.active = true
        source.state.obsolete_reason_id = nil
        expect(values['status']).to eq 'Active'
      end

      it 'NOT active and not Obsolete returns In Progress' do
        source.active = false
        source.state.obsolete_reason_id = nil
        expect(values['status']).to eq 'In Progress'
      end

      it 'obsolete and inactive returns Suspended' do
        source.active = false
        source.state.obsolete_reason_id = 1
        expect(values['status']).to eq 'Suspended'
      end

      it 'obsolete and active returns Suspended' do
        source.active = true
        source.state.obsolete_reason_id = 1
        expect(values['status']).to eq 'Suspended'
      end
    end

    context '#suspended_reason' do
      it 'should have a nil reason if there is no obsolete reason name' do
        source.state.obsolete_reason_name = nil
        expect(values['suspended_reason']).to be_nil
      end

      it 'should have a reason if there is a obsolete reason name' do
        source.state.obsolete_reason_name = 'Anything but Bears'
        expect(values['suspended_reason']).to eq('Anything but Bears')
      end
    end

    context '#live' do
      before do
        source.active = true
        source.allow_exposure = true
        source.inventory.total_avail_qty = 1
        source.state.exists_in_storefront = true
      end
      let(:live) { values['live'] }

      it('live with all settings') { expect(live).to be_truthy }

      context 'not live when' do
        after { expect(live).to be_falsey }
        it('not active') { source.active = false }
        it('not exposed') { source.allow_exposure = false }
        it('no inventory') { source.inventory.total_avail_qty = 0 }
        it('not in storefront') { source.state.exists_in_storefront = false }
        it('obsolete') { source.state.obsolete_reason_id = 1 }
      end
    end

    context '#shipping_method' do
      let(:shipping_method) { values['shipping_method'] }

      it 'entryway is Threshold, White Glove' do
        source.shipping.entryway = true
        expect(shipping_method).to eq 'Threshold, White Glove'
      end

      it 'white glove but not entryway is White Glove' do
        source.shipping.entryway = false
        source.shipping.white_glove = true
        expect(shipping_method).to eq 'White Glove'
      end

      it 'non-entryway, non-White Glove is Standard' do
        source.shipping.entryway = false
        source.shipping.white_glove = false
        expect(shipping_method).to eq 'Standard'
      end
    end

    context '#limited_qty' do
      let(:limited_qty) { values['limited_qty'] }
      it 'true when total_avail_qty is nil' do
        source.inventory.total_avail_qty = nil
        expect(limited_qty).to be_truthy
      end

      it 'true when total_avail_qty is 4' do
        source.inventory.total_avail_qty = 4
        expect(limited_qty).to be_truthy
      end

      it 'false when total_avail_qty is 5' do
        source.inventory.total_avail_qty = 5
        expect(limited_qty).to be_falsey
      end
    end

    context '#returnable' do
      it 'false when returnable is nil' do
        expect(values['returnable']).to be false
      end
    end

    context '#made_to_order' do
      let(:please_note) { source.sku_attributes.build(code: 'please_note') }
      let(:made_to_order) { values['made_to_order'] }

      it 'false when no please note value' do
        expect(made_to_order).to be false
      end

      it 'false when please note does not match' do
        please_note.value = 'Roll on you bears'
        expect(made_to_order).to be false
      end

      it "true when please note includes 'made to order'" do
        please_note.value = 'This product is made to order'
        expect(made_to_order).to be true
      end

      it "true when please note includes 'MaDe to OrdeR'" do
        please_note.value = 'This product is MaDe to OrdeR'
        expect(made_to_order).to be true
      end

      it "true when please note includes 'cut to order'" do
        please_note.value = 'This product is cut to order'
        expect(made_to_order).to be true
      end

      it "true when please note includes 'finished to order'" do
        please_note.value = 'This product is finished to order'
        expect(made_to_order).to be true
      end
    end

    context '#assembly_required' do
      let(:please_note) { source.sku_attributes.build(code: 'please_note') }
      let(:assembly_required) { values['assembly_required'] }

      it 'false when no please note value' do
        expect(assembly_required).to be false
      end

      it 'true when please note includes assembly required' do
        please_note.value = 'some assembly required'
        expect(assembly_required).to be true
      end

      it 'true when please not includes assembly IS required' do
        please_note.value = 'some assembly is required'
        expect(assembly_required).to be true
      end

      it 'true when please not includes assembly may be required' do
        please_note.value = 'some assembly may be required'
        expect(assembly_required).to be true
      end

      it 'false when please note includes no assembly required' do
        please_note.value = 'no assembly required'
        expect(assembly_required).to be false
      end
    end
  end
end
