require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::ECOM::CommerceHub,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) { External::ECOM::CommerceHub.new }
  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::Sku.new }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'vendor_discontinued_at' do
      source.discontinued_dt = '1976-07-06'.to_datetime
      expect(values['vendor_discontinued_at']).to eq '1976-07-06'.to_datetime
    end

    it 'vendor_available_qty' do
      source.curr_qty = 123
      expect(values['vendor_available_qty']).to eq 123
    end

    it 'vendor_availability_status uses title case' do
      source.availability_status = 'YES'
      expect(values['vendor_availability_status']).to eq 'Yes'
    end

    it 'vendor_next_available_qty' do
      source.next_avail_qty = 234
      expect(values['vendor_next_available_qty']).to eq 234
    end

    it 'vendor_next_available_at' do
      source.next_avail_dt = '1976-07-06'.to_datetime
      expect(values['vendor_next_available_at']).to eq '1976-07-06'.to_datetime
    end

    it 'vendor_inventory_last_updated_at' do
      source.comhub_mod_dt = '1976-07-06'.to_datetime
      expect(values['vendor_inventory_last_updated_at']).to eq '1976-07-06'.to_datetime
    end
  end
end
