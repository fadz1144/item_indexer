require 'rails_helper'

class MockAssociation
  attr_accessor :class_name
  def initialize(name)
    @class_name = "#{name.to_s.singularize.titlecase}Model"
  end
end

class MockModel
  attr_accessor :attributes
  class_attribute :attribute_names

  def self.reflect_on_association(name)
    MockAssociation.new(name)
  end

  def initialize(attributes)
    @attributes = attributes
  end
end

class CoachModel < MockModel; self.attribute_names = %w[team_id name nickname prop_id]; end
class PlayerModel < MockModel; self.attribute_names = %w[team_id number name prop_id]; end

class TeamModel < MockModel
  self.attribute_names = %w[team_id name prop_id]

  def build_coach(coach_attributes)
    CoachModel.new({ 'team_id' => attributes['team_id '] }.merge(coach_attributes))
  end

  def players
    @players ||= Class.new(Array) do
      def initialize(team_id)
        @team_id = team_id
      end

      def build(player_attributes)
        PlayerModel.new({ 'team_id' => @team_id }.merge(player_attributes)).tap do |player|
          push(player)
        end
      end
    end.new(attributes['team_id'])
  end
end

class TeamMessage < CatalogMessage::Base
  model 'TeamModel'
  has_one :coach
  has_many :players
end

class TeamMessageProp < TeamMessage; propagate_attributes 'prop_id'; end
class TeamMessageMap < TeamMessage; attribute_mapping 'name' => 'team_name'; end

class OtherTeamMessage < CatalogMessage::Base
  model 'TeamModel'
  has_one :nested, model_name: 'CoachModel'
end

RSpec.describe CatalogMessage::Base do
  let(:message_data) do
    { team_id: 123,
      name: 'Golden Bears',
      prop_id: 345,
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
      expect(team.attributes).to include(message_data.slice('team_id', 'name'))
    end

    it 'populates coach' do
      expect(coach.attributes).to include(message_data['coach'])
    end

    it 'populates two players' do
      expect(players.size).to eq 2
    end

    it 'knows Joe Roth' do
      joe = message_data['players'].find { |p| p['name'] == 'Joe' }
      expect(players.map(&:attributes)).to include(joe.merge('team_id' => 123))
    end
  end

  context 'propagate' do
    let(:records) { TeamMessageProp.new(message_data).records }

    it 'propagates prop_id to coach' do
      expect(coach.attributes).to include('prop_id' => 345)
    end

    it 'propagates prop_id to players' do
      expect(players.first.attributes).to include('prop_id' => 345)
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
    expect(OtherTeamMessage.associations.size).to eq 1
  end
end
