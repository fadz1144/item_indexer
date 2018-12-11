require 'rails_helper'

RSpec.describe SOLR::Decorators::ConstantAttributeBuckets do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::ConstantAttributeBuckets

      constants_class = Class.new do
        attr_reader :constants

        def initialize(constants)
          @constants = constants
        end
      end.new %w[Cardinal White]

      bucket 'some_constants', constants_class

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, which_concepts: concepts))
  end

  context 'one' do
    let(:concepts) { [1] }
    it { expect { serializer.some_constants_cardinal }.not_to raise_exception }
    it { expect { serializer.some_constants_white }.not_to raise_exception }
    it { expect { serializer.some_constants_blue }.to raise_error(NoMethodError) }
  end

  context 'constants' do
    let(:concepts) { [2] }
    it { expect(serializer.respond_to?(:cardinal?)) }
    it { expect(serializer.respond_to?(:white?)) }
    it { expect(!serializer.respond_to?(:blue?)) }
  end

  context 'concept ids as result' do
    let(:concepts) { [3] }
    it { expect(serializer.some_constants_cardinal).to eq [3] }
  end
end
