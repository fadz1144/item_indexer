require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::ConceptBrand do
  let(:source) { Inbound::OKL::BrandRevision.new }
  let(:target) { described_class.target_class.new }
  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context '#apply_transformation' do
    let(:results) do
      transformer.apply_transformation(target)
      target
    end

    context '#name' do
      it 'uses name when present' do
        source.name = 'Oski'
        expect(results.name).to eq 'Oski'
      end

      it 'uses description when name nil' do
        source.description = 'Go Bears!'
        expect(results.name).to eq 'Go Bears!'
      end

      it 'uses description when name is blank' do
        source.name = ''
        source.description = 'Blue'
        expect(results.name).to eq 'Blue'
      end

      it 'uses description when name is blank space' do
        source.name = ' '
        source.description = 'Blue'
        expect(results.name).to eq 'Blue'
      end
    end
  end

  context 'when no matching brand exists' do
    before do
      source.name = 'Oski'
      transformer.apply_transformation(target)
    end

    it 'creates brand' do
      expect(target.brand).to be_new_record
    end
  end

  context 'when matching brand exists' do
    let(:existing_brand) { CatModels::Brand.create(name: 'Oski') }

    before do
      source.name = existing_brand.name
      transformer.apply_transformation(target)
    end

    it 'finds match' do
      expect(target.brand).to eq existing_brand
    end

    context 'when match is due to blank names' do
      let(:existing_brand) { CatModels::Brand.create }

      it 'creates brand' do
        expect(target.brand).to be_new_record
      end
    end
  end
end
