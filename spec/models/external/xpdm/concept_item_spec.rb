require 'rails_helper'

RSpec.describe External::XPDM::ConceptItem do
  let(:parent) { double('parent', concept_description: 'foo') }
  let(:state) { double('state', web_site_cd: 'bar') }
  let(:web_info_site) { double('web_info_site', web_status_flg: web_status_flg) }
  let(:additional_associations) { { web_info_site: web_info_site } }
  let(:concept_item) { described_class.new(parent, state, additional_associations) }

  context '#web_status' do
    context 'active' do
      let(:web_status_flg) { 'A' }
      it 'value for known code' do
        expect(concept_item.web_status).to eq(CatModels::Constants::SystemStatus::ACTIVE)
      end
    end

    context 'unknown' do
      let(:web_status_flg) { 'X' }
      it 'unknown value for unrecognized code' do
        expect(concept_item.web_status).to eq(CatModels::Constants::SystemStatus::UNKNOWN)
      end
    end
  end
end
