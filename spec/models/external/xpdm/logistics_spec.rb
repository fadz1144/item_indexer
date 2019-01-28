require 'rails_helper'

RSpec.describe External::XPDM::Logistics, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:logistics) { described_class.new }
  context 'personalizable?' do
    it 'not when no code' do
      expect(logistics.personalizable?).to be false
    end

    it 'not when U - Unknown' do
      logistics.cstmzn_type_cd = 'U'
      expect(logistics.personalizable?).to be false
    end

    it 'not when N - Customization not available' do
      logistics.cstmzn_type_cd = 'N'
      expect(logistics.personalizable?).to be false
    end

    it 'is MO - Monogram' do
      logistics.cstmzn_type_cd = 'MO'
      expect(logistics.personalizable?).to be true
    end
  end
end
