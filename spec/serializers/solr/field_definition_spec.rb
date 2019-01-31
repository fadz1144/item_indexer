require 'rails_helper'

RSpec.describe SOLR::FieldDefinition do
  context 'solr_field_definition' do
    it 'includes specified options' do
      options = { type: 'bears', indexed: true, stored: true, multiValued: false }
      f = described_class.new('oski', options)
      expect(f.solr_field_definition).to match(options.merge(name: 'oski'))
    end

    it 'excludes non-solr options' do
      options = { type: 'bears', blue: true }
      f = described_class.new('oski', options)
      expect(f.solr_field_definition.keys).not_to include(:blue)
    end
  end

  it '#name' do
    options = { type: 'bears' }
    f = described_class.new('oski', options)
    expect(f.name).to eq :oski
  end

  context '#source_name' do
    it 'falls back to name when not specified' do
      options = { type: 'bears' }
      f = described_class.new('oski', options)
      expect(f.source_name).to eq :oski
    end

    it 'returns source name when specified' do
      options = { type: 'bears', source_name: 'bear' }
      f = described_class.new('oski', options)
      expect(f.source_name).to eq :bear
    end
  end
end
