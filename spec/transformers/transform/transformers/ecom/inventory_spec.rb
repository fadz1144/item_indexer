require 'rails_helper'

RSpec.describe Transform::Transformers::ECOM::Inventory, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:inv_source) { 'W' }
  let(:source) { External::ECOM::Inventory.new(afs_qty: 10, inv_source: inv_source) }
  let(:transformer) { described_class.new(source) }
  let(:concept_id) { 1 }
  let(:target) { CatModels::ConceptSku.new(concept_id: concept_id) }

  it '#apply_transformation does not raise error' do
    expect { transformer.apply_transformation(target) }.not_to raise_exception
  end

  shared_examples 'total and warehouse are 21' do
    it('total_avail_qty') { expect(target.total_avail_qty).to eq 21 }
    it('warehouse_avail_qty') { expect(target.warehouse_avail_qty).to eq 21 }
    it('vdc_avail_qty') { expect(target.vdc_avail_qty).to be_zero }
  end

  context 'BBBY' do
    before do
      source.bbb_alt_afs_qty = 11
      transformer.apply_transformation(target)
    end

    it_behaves_like 'total and warehouse are 21'

    context 'vdc' do
      let(:inv_source) { 'V' }
      it('total_avail_qty') { expect(target.total_avail_qty).to eq 21 }
      it('warehouse_avail_qty') { expect(target.warehouse_avail_qty).to be_zero }
      it('vdc_avail_qty') { expect(target.vdc_avail_qty).to eq 21 }
    end
  end

  context 'BABY' do
    let(:concept_id) { 4 }
    before do
      source.bab_alt_afs_qty = 11
      transformer.apply_transformation(target)
    end

    it_behaves_like 'total and warehouse are 21'
  end

  context 'CA' do
    let(:concept_id) { 2 }
    before do
      source.ca_alt_afs_qty = 11
      transformer.apply_transformation(target)
    end

    it_behaves_like 'total and warehouse are 21'
  end
end
