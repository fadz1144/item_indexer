require 'rails_helper'

class MockModel
  attr_accessor :attributes
  class_attribute :attribute_names
  def initialize(attributes)
    @attributes = attributes
  end
end

class TeamModel < MockModel; self.attribute_names = %w[team_id name]; end
class CoachModel < MockModel; self.attribute_names = %w[team_id name nickname]; end
class PlayerModel < MockModel; self.attribute_names = %w[team_id number name]; end

class TeamMessage < CatalogMessage::Base
  model_name 'TeamModel'
  has_one :coach, model_name: 'CoachModel'
  has_many :players, model_name: 'PlayerModel'
end

class TeamMessageProp < TeamMessage; propagate 'team_id'; end
class TeamMessageMap < TeamMessage; attribute_mapping 'name' => 'team_name'; end

class OtherTeamMessage < CatalogMessage::Base
  model_name 'TeamModel'
  has_one :nested, model_name: 'CoachModel'
end

RSpec.describe CatalogMessage::Base do
  let(:message_data) do
    { team_id: 123,
      name: 'Golden Bears',
      coach: { name: 'Pappy', nickname: 'Coach' },
      players: [{ number: 12, name: 'Joe' }, { number: 8, name: 'Deltha' }] }.as_json
  end
  let(:coach) { records.find { |r| r.class == CoachModel } }
  let(:players) { records.select { |r| r.class == PlayerModel } }

  context '#records' do
    let(:records) { TeamMessage.new(message_data).records }

    it 'includes team, coach, and two player models' do
      expect(records.map(&:class)).to contain_exactly(TeamModel, CoachModel, PlayerModel, PlayerModel)
    end

    it 'populates team' do
      team = records.find { |r| r.class == TeamModel }
      expect(team.attributes).to match(message_data.slice('team_id', 'name'))
    end

    it 'populates coach' do
      expect(coach.attributes).to match(message_data['coach'])
    end

    it 'populates both players' do
      expect(players.map(&:attributes)).to match(message_data['players'])
    end
  end

  context 'propagate' do
    let(:records) { TeamMessageProp.new(message_data).records }

    it 'propagates team_id to coach' do
      expect(coach.attributes).to include('team_id' => 123)
    end

    it 'propagates team_id to players' do
      expect(players.first.attributes).to include('team_id' => 123)
    end
  end

  context 'attribute mapping' do
    let(:message_data_map) { message_data.tap { |d| d['team_name'] = d.delete('name') } }

    it 'maps team_name to team' do
      team = TeamMessageMap.new(message_data_map).records.find { |r| r.class == TeamModel }
      expect(team.attributes['name']).to eq 'Golden Bears'
    end
  end

  it 'associations are not accumulated' do
    expect(OtherTeamMessage._associations.size).to eq 1
  end
end
