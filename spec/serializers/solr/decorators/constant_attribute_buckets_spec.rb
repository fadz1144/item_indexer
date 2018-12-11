require 'rails_helper'

module SOLR
  module Decorators
    module Constants
      class TestConstants
        CONSTANT_ONE = 'Constant 1'.freeze
        CONSTANT_TWO = 'Constant Two'.freeze
      end
    end
  end
end

RSpec.describe SOLR::Decorators::ConstantAttributeBuckets do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::ConstantAttributeBuckets

      bucket 'some_constants', SOLR::Decorators::Constants::TestConstants

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, which_concepts: concepts))
  end

  context 'one' do
    let(:concepts) { Object.new }
    it { expect { serializer.some_constants_constant_one }.not_to raise_exception }
    it { expect { serializer.some_constants_constant_two }.not_to raise_exception }
    it { expect { serializer.some_constants_constant_three }.to raise_error(NoMethodError) }
  end
end
