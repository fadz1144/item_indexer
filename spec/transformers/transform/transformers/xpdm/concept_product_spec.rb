require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::ConceptProduct,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) do
    External::XPDM::ConceptProduct.new(External::XPDM::Product.new,
                                       External::XPDM::State.new(web_site_cd: 'BBBY'),
                                       description: External::XPDM::Description.new)
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::ConceptProduct.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'
end
