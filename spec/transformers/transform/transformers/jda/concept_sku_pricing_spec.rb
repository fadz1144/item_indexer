require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::JDA::ConceptSkuPricing do
  let(:source) { Inbound::JDA::PricingChange.new }
  let(:target) { CatModels::ConceptSkuPricing.new }

  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'
end
