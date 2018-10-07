require 'rails_helper'

RSpec.describe External::XPDM::ConceptSkuDescription, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:default) { External::XPDM::Description.new(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'ALL') }
  let(:item_master) { External::XPDM::Description.new(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'USA') }
  let(:description) { described_class.new([default, item_master]) }

  %w[mstr_prod_desc mstr_shrt_desc mstr_web_desc prod_desc vdr_web_prod_desc].each do |name|
    it "##{name}" do
      default.public_send("#{name}=", 'oski')
      expect(description.public_send(name)).to eq 'oski'
    end
  end

  %w[jda_desc pos_desc].each do |name|
    it "##{name}" do
      item_master.public_send("#{name}=", 'oski')
      expect(description.public_send(name)).to eq 'oski'
    end
  end
end
