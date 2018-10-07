require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::ConceptSkuImage,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) do
    External::XPDM::Image.new(
      External::XPDM::ImageRelation.new(item_code_name_cd: 'IMG_123', item_code_name: 'oski.jpg')
    )
  end

  let(:transformer) { described_class.new(source) }
  let(:target) do
    CatModels::ConceptSkuImage.new(concept_sku: CatModels::ConceptSku.new(sku: CatModels::Sku.new))
  end
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'
end
