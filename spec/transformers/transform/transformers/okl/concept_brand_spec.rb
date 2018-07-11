require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptBrand do
  let(:source) { Inbound::OKL::BrandRevision.new }
  let(:target) { described_class.target_class.new }
  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'
end
