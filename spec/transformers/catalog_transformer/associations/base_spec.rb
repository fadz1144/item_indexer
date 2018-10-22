require 'rails_helper'

# The test scenario is a Conference source data that updates parent League, child commissioner, and children teams, as
# well as for each team the coach and players.
module CatalogTransformerAssociationsBaseTests
  class TestTransformer < CatalogTransformer::Base
    # prevents attributes from being built, which requires target class as ActiveRecord
    def self.attributes
      []
    end

    # prevents reflection on target class during transformer class method target_includes
    def self.additional_belongs_to_on_target
      []
    end
  end

  class Conference < TestTransformer
    # override this method to eliminate need for fake Conference model
    def self.association_foreign_key(*)
      'mock'
    end

    belongs_to :league, source_name: :league_source
    has_one :commissioner
    has_many :teams, source_name: :teams_source
  end

  class League < TestTransformer; end

  # while the commissioner info is on the conference source record, the commissioner's hat has it's own source
  # that's interesting here because while commissioner does not generate a source_includes, the hat does!
  class Commissioner < TestTransformer
    has_one :hat, source_name: :commissioner_hat_source
  end

  class Hat < TestTransformer; end

  class Team < TestTransformer
    has_one :coach
    has_many :players, source_name: :players_source
  end

  class Coach < TestTransformer
  end

  class Player < TestTransformer
  end
end

RSpec.describe CatalogTransformer::Associations::Base do
  let(:comm_name) { 'CatalogTransformerAssociationsBaseTests::Commissioner' }
  let(:league_name) { 'CatalogTransformerAssociationsBaseTests::League' }
  let(:team_name) { 'CatalogTransformerAssociationsBaseTests::Team' }

  context 'association with no source' do
    let(:association) { described_class.new(:commissioner, nil, comm_name, nil) }

    it 'specifies source includes from nested transformers' do
      expect(association.source_includes).to eq [:commissioner_hat_source]
    end

    it 'specifies target includes' do
      expect(association.target_includes).to eq(commissioner: [:hat])
    end

    it 'returns :itself for source_name' do
      expect(association.source_name).to eq :itself
    end
  end

  context 'association with source' do
    let(:association) { described_class.new(:league, :league_source, league_name, nil) }

    it 'specifies source includes' do
      expect(association.source_includes).to eq(:league_source)
    end

    it 'specifies target includes' do
      expect(association.target_includes).to eq(:league)
    end

    it 'specifies source name' do
      expect(association.source_name).to eq :league_source
    end
  end

  context 'association with nested includes' do
    let(:association) { described_class.new(:teams, :teams_source, team_name, nil) }

    it 'specifies target includes' do
      expect(association.target_includes).to eq(teams: %i[coach players])
    end

    it 'specifies source includes' do
      expect(association.source_includes).to eq(teams_source: [:players_source])
    end
  end
end
