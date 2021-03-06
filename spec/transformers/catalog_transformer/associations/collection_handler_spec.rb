require 'rails_helper'

RSpec.describe CatalogTransformer::Associations::CollectionHandler do
  let(:player_class) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :name, :number, :marked_for_destruction
      def initialize(number = nil, name = nil)
        @name = name
        @number = number
        @marked_for_destruction = false
      end

      def mark_for_destruction
        @marked_for_destruction = true
      end

      def to_h
        { @number => @name }
      end
    end
  end

  # fake the association by allowing the array to receive build and return a new player that it has appended
  let(:players) do
    Class.new(Array) do
      attr_accessor :player_class
      def self.init_with_build_class(player_class, *data)
        new.push(*data).tap { |a| a.player_class = player_class }
      end

      def build
        @player_class.new.tap { |p| push(p) }
      end
    end
  end

  let(:one) { player_class.new(1, 'A') }
  let(:two) { player_class.new(2, 'B') }
  let(:three) { player_class.new(3, 'C') }
  let(:three_changed) { player_class.new(3, 'Not C') }
  let(:four) { player_class.new(4, 'D') }
  let(:five) { player_class.new(5, 'E') }

  let(:target) { double('TargetTeam', players: players.init_with_build_class(player_class, one, two, three)) }
  let(:source) { double('SourceTeam', source_players: [three_changed, four, five]) }
  let(:partial) { false }

  let(:association) do
    CatalogTransformer::Associations::CollectionAssociation.new(:players, :source_players,
                                                                CatalogTransformer::Base.to_s, :number, partial)
  end

  let(:attributes) { %w[number name].map { |n| CatalogTransformer::Attributes::Attribute.new(n) } }
  before do
    allow(CatalogTransformer::Base).to receive(:attributes).and_return(attributes)
    association.handler_for(source, target).transform_association(association)
  end

  shared_examples 'it adds, updates, and destroys correctly' do
    it 'target has all five' do
      expect(target.players.map(&:number)).to contain_exactly(1, 2, 3, 4, 5)
    end

    it 'marks one and two for destruction' do
      expect(target.players.select(&:marked_for_destruction).map(&:number)).to contain_exactly(1, 2)
    end

    it 'updates three' do
      target_three = target.players.find { |p| p.number == 3 }
      expect(target_three.name).to eq 'Not C'
    end
  end

  it_behaves_like 'it adds, updates, and destroys correctly'

  context 'with match keys that have different names' do
    let(:tres) { double('SourcePlayerThree', numero: 3, name: 'Not C') }
    let(:quatro) { double('SourcePlayerFour', numero: 4, name: 'D') }
    let(:cinco) { double('SourcePlayerFive', numero: 5, name: 'E') }
    let(:source) { double('SourceTeam', source_players: [tres, quatro, cinco]) }

    let(:attributes) do
      [CatalogTransformer::Attributes::Attribute.new(:name),
       CatalogTransformer::Attributes::Attribute.new(:number, source_name: :numero)]
    end

    it_behaves_like 'it adds, updates, and destroys correctly'
  end

  context 'with partial data set' do
    let(:partial) { true }

    it 'does not mark any for destruction' do
      expect(target.players.select(&:marked_for_destruction)).to be_empty
    end
  end
end
