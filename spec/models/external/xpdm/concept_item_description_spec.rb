require 'rails_helper'

RSpec.describe External::XPDM::ConceptItemDescription, skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:default) { External::XPDM::Description.new(web_site_id: 'ALL', language_cd: 'ALL', country_cd: 'ALL') }
  let(:extra) { instance_spy(External::XPDM::Description) }
  let(:description) { described_class.new([default, extra]) }

  %w[mstr_prod_desc mstr_shrt_desc mstr_web_desc prod_desc vdr_web_prod_desc].each do |name|
    it "##{name}" do
      default.public_send("#{name}=", 'oski')
      expect(description.public_send(name)).to eq 'oski'
    end
  end

  context 'when no default' do
    let(:first) { instance_spy(External::XPDM::Description) }
    let(:description) { described_class.new([first, extra]) }

    it 'uses first' do
      description.mstr_prod_desc
      expect(first).to have_received(:mstr_prod_desc)
    end
  end
end
