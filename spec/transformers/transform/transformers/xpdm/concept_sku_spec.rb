require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::ConceptSku,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:sku) do
    External::XPDM::Sku.new.tap do |s|
      s.states.build(web_site_cd: 'BBBY')
      s.descriptions.build(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'ALL', mstr_prod_desc: 'Oski',
                           mstr_shrt_desc: 'Golden Bear', mstr_web_desc: 'Roll on you Bears!')
      s.descriptions.build(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'USA',
                           jda_desc: 'Blue', pos_desc: 'Gold')
    end
  end
  let(:source) { External::XPDM::ConceptSku.from_parent(sku).first }

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::ConceptSku.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'

  context '#apply_transformation' do
    let(:results) do
      transformer.apply_transformation(target)
      target
    end

    context 'inventory' do
      before do
        target.total_avail_qty = 123
        target.warehouse_avail_qty = 234
        target.vdc_avail_qty = 345
      end

      context 'is not loaded' do
        it('does not update total_avail_qty') { expect(results.total_avail_qty).to eq 123 }
        it('does not update warehouse_avail_qty') { expect(results.warehouse_avail_qty).to eq 234 }
        it('does not update vdc_avail_qty') { expect(results.vdc_avail_qty).to eq 345 }
      end

      context 'is loaded' do
        before { sku.build_inventory(afs_qty: 111, bbb_alt_afs_qty: 222, inv_source: 'W') }
        it('updates total_avail_qty') { expect(results.total_avail_qty).to eq 333 }
        it('updates warehouse_avail_qty') { expect(results.warehouse_avail_qty).to eq 333 }
        it('updates vdc_avail_qty') { expect(results.vdc_avail_qty).to eq 0 }
      end

      context 'canadian_sku_not_sellable_there?' do
        before { sku.build_inventory(afs_qty: 111, bbb_alt_afs_qty: 222, inv_source: 'W') }
        let(:compliance) { sku.build_compliance }

        it 'is not loaded when canadian sku not sellable there' do
          allow(source).to receive(:concept_id).and_return(2)
          allow(compliance).to receive(:sellable_in_canada?).and_return(false)
          expect(results.total_avail_qty).to eq 123
        end
      end
    end
  end

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it('name') { expect(values['name']).to eq 'Oski' }
    it('description') { expect(values['description']).to eq 'Golden Bear' }
    it('details') { expect(values['details']).to eq 'Roll on you Bears!' }
  end
end
