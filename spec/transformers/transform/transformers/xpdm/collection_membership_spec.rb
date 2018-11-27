require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::CollectionMembership,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) do
    External::XPDM::CollectionMembership.new(item_code_name_cd: '123', rlate_item_dsply_seq_num: 100)
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::CollectionMembership.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'
end
