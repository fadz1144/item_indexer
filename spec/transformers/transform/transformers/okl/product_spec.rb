require 'rails_helper'

RSpec.describe Transform::Transformers::OKL::Product do
  let(:source) { Inbound::OKL::ProductRevision.new }
  let(:transformer) { described_class.new(source) }

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'does not error' do
      expect { values }.not_to raise_exception
    end
  end
end
