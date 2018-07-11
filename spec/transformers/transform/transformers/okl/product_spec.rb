require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::Product do
  let(:source) { Inbound::OKL::ProductRevision.new }
  let(:target) { CatModels::Product.new }
  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'
end
