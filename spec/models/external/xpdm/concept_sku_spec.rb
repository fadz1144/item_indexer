require 'rails_helper'

RSpec.describe External::XPDM::ConceptSku,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  context '.from_parent' do
    let(:sku) do
      External::XPDM::Sku.new.tap do |sku|
        sku.states = [External::XPDM::State.new(web_site_cd: 'BBBY'),
                      External::XPDM::State.new(web_site_cd: 'CA'),
                      External::XPDM::State.new(web_site_cd: 'BABY')]
        sku.web_prices = [External::XPDM::WebPrice.new(web_site_cd: 'BBBY', web_reg_prc_amt: 123.45),
                          External::XPDM::WebPrice.new(web_site_cd: 'CA', web_reg_prc_amt: 234.56),
                          External::XPDM::WebPrice.new(web_site_cd: 'BABY', web_reg_prc_amt: 345.67)]
        sku.web_costs = [External::XPDM::WebCost.new(site_id: 'BBBY', web_cst_amt: 111.11),
                         External::XPDM::WebCost.new(site_id: 'CA', web_cst_amt: 222.22),
                         External::XPDM::WebCost.new(site_id: 'BABY', web_cst_amt: 333.33)]
      end
    end
    let(:concept_skus) { described_class.from_parent(sku) }
    let(:bbby_cs) { concept_skus.find { |cs| cs.concept_id == 1 } }
    let(:ca_cs) { concept_skus.find { |cs| cs.concept_id == 2 } }
    let(:baby_cs) { concept_skus.find { |cs| cs.concept_id == 4 } }

    it('has BBBY price') { expect(bbby_cs.price).to eq 123.45 }
    it('has CA price') { expect(ca_cs.price).to eq 234.56 }
    it('has BABY price') { expect(baby_cs.price).to eq 345.67 }

    it('has BBBY cost') { expect(bbby_cs.cost).to eq 111.11 }
    it('has CA cost') { expect(ca_cs.cost).to eq 222.22 }
    it('has BABY cost') { expect(baby_cs.cost).to eq 333.33 }
  end
end
