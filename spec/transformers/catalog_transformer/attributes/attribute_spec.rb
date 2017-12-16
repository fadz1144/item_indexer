require 'rails_helper'

RSpec.describe CatalogTransformer::Attributes::Attribute do
  context 'no associations present' do
    let(:attribute) { described_class.new(:oski) }

    it 'returns attribute name as string' do
      expect(attribute.name).to eq 'oski'
    end

    it 'returns itself for source_record_name' do
      expect(attribute.source_record_name).to eq :itself
    end

    it 'has no target_includes' do
      expect(attribute.target_includes).to be_nil
    end

    it 'has no for source_includes' do
      expect(attribute.source_includes).to be_nil
    end
  end

  context 'value comes from source association' do
    let(:attribute) { described_class.new(:oski, association: :coach) }

    it 'returns association name as source_record_name' do
      expect(attribute.source_record_name).to eq :coach
    end

    it 'has no target_includes' do
      expect(attribute.target_includes).to be_nil
    end

    it 'includes association in source_includes' do
      expect(attribute.source_includes).to eq(:coach)
    end
  end

  context 'both associations share same name' do
    # these are system generated references
    let(:attribute) { CatalogTransformer::Attributes::ReferenceAttribute.new(:coach) }

    it 'returns itself as source_record_name (since it is not nested)' do
      expect(attribute.source_record_name).to eq :itself
    end

    it 'returns association name as source_name' do
      expect(attribute.source_name).to eq :coach
    end

    it 'includes association in target_includes' do
      expect(attribute.target_includes).to eq(:coach)
    end

    it 'includes association in source_includes' do
      expect(attribute.source_includes).to eq(:coach)
    end
  end

  context 'source association has different name than target' do
    let(:attribute) { CatalogTransformer::Attributes::ReferenceAttribute.new(:coach, source_name: :manager) }

    it 'returns itself as source_record_name (since it is not nested)' do
      expect(attribute.source_record_name).to eq :itself
    end

    it 'returns the specified source_name' do
      expect(attribute.source_name).to eq :manager
    end

    it 'includes association in target_includes' do
      expect(attribute.target_includes).to eq(:coach)
    end

    it 'includes association in source_includes' do
      expect(attribute.source_includes).to eq(:manager)
    end
  end

  context 'source association is nested' do
    let(:attribute) { CatalogTransformer::Attributes::ReferenceAttribute.new(:coach, association: :team) }

    it 'returns wrapping association name as source_record_name' do
      expect(attribute.source_record_name).to eq :team
    end

    it 'returns association name as source_name' do
      expect(attribute.source_name).to eq :coach
    end

    it 'includes association in target_includes' do
      expect(attribute.target_includes).to eq(:coach)
    end

    it 'includes nested association in source_includes' do
      expect(attribute.source_includes).to eq(team: :coach)
    end
  end

  context 'source association is nested with different name' do
    let(:attribute) do
      CatalogTransformer::Attributes::ReferenceAttribute.new(:coach, association: :team, source_name: :manager)
    end

    it 'returns wrapping association name as source_record_name' do
      expect(attribute.source_record_name).to eq :team
    end

    it 'returns the specified source_name' do
      expect(attribute.source_name).to eq :manager
    end

    it 'includes association in target_includes' do
      expect(attribute.target_includes).to eq(:coach)
    end

    it 'includes nested association in source_includes' do
      expect(attribute.source_includes).to eq(team: :manager)
    end
  end
end
