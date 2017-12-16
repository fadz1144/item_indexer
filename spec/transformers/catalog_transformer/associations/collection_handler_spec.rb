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

  let(:association) do
    CatalogTransformer::Associations::CollectionAssociation.new(:players, :source_players,
                                                                CatalogTransformer::Base.to_s, :number)
  end

  let(:transformer) { described_class.new(source, target) }
  before do
    allow(CatalogTransformer::Base).to receive(:attributes_from_model).and_return(%w[name number])
    allow(CatalogTransformer::Base).to receive(:references_from_model).and_return({})
    described_class.new(source, target).transform_association(association)
  end

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
