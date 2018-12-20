require 'rails_helper'

RSpec.describe External::XPDM::Compliance, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:compliance) { described_class.new }

  context '#sellable_in_canada?' do
    it('defaults to false') { expect(compliance.sellable_in_canada?).to be false }

    it 'true when transferable' do
      compliance.transfrbl_to_ca_ind = 'Y'
      expect(compliance.sellable_in_canada?).to be true
    end

    it 'true when avail_for_dstrbn_ca_cd present' do
      compliance.avail_for_dstrbn_ca_cd = 'oski'
      expect(compliance.sellable_in_canada?).to be true
    end

    it 'true when ec_fulfil_rule_ca_cd = E' do
      compliance.ec_fulfil_rule_ca_cd = 'E'
      expect(compliance.sellable_in_canada?).to be true
    end

    it 'true when ec_fulfil_rule_ca_cd = R' do
      compliance.ec_fulfil_rule_ca_cd = 'R'
      expect(compliance.sellable_in_canada?).to be true
    end
  end
end
