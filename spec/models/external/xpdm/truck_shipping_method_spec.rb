require 'rails_helper'

RSpec.describe External::XPDM::TruckShippingMethod, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:shipping_method) { described_class.new }

  context '#shipping_method' do
    it 'nil' do
      expect(shipping_method.shipping_method).to be_nil
    end
    context 'is Threshold for' do
      after { expect(shipping_method.shipping_method).to eq 'Threshold' }
      it('Threshold') { shipping_method.ltl_elg_shp_meth_name = 'Threshold' }
      it('Threshold Special') { shipping_method.ltl_elg_shp_meth_name = 'Threshold Special' }
    end

    context 'is Room of Choice for' do
      after { expect(shipping_method.shipping_method).to eq 'Room of Choice' }
      it('Room Of Choice') { shipping_method.ltl_elg_shp_meth_name = 'Room Of Choice' }
      it('Room Of Choice Special') { shipping_method.ltl_elg_shp_meth_name = 'Room Of Choice Special' }
    end

    context 'is White Glove for' do
      after { expect(shipping_method.shipping_method).to eq 'White Glove' }
      it('White Glove') { shipping_method.ltl_elg_shp_meth_name = 'White Glove' }
      it('White Glove Special') { shipping_method.ltl_elg_shp_meth_name = 'White Glove Special' }
    end

    it 'returns nil for other values' do
      shipping_method.ltl_elg_shp_meth_name = 'Nearby'
      expect(shipping_method.shipping_method).to be_nil
    end
  end

  context '.uniq_and_ordered_shipping_methods' do
    let(:shipping_methods) do
      [described_class.new(ltl_elg_shp_meth_name: 'White Glove Special'),
       described_class.new(ltl_elg_shp_meth_name: 'Threshold'),
       described_class.new(ltl_elg_shp_meth_name: 'Room Of Choice'),
       described_class.new(ltl_elg_shp_meth_name: 'Nearby'),
       described_class.new(ltl_elg_shp_meth_name: 'Room Of Choice')]
    end

    it 'returns uniq, sorted, and valid methods' do
      expect(described_class.shipping_methods(shipping_methods)).to eq 'Threshold, Room of Choice, White Glove'
    end
  end
end
