require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::DW::ConceptSkuPricing do
  let(:source) { Inbound::DW::ContributionMarginFeed.new }
  let(:target) { CatModels::ConceptSkuPricing.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'
end
