require 'rails_helper'

RSpec.describe SOLR::Decorators::ConceptSkuUniqDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::ConceptSkuUniqDecoratedAttribute

      decorate_concept_sku_uniq 'description', field: 'description'
      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, concept_skus_iterator_uniq: values))
  end

  context 'single desc' do
    let(:values) { ['Some description'] }
    it { expect(serializer.description).to eql ['Some description'] }
  end

  context 'multi desc' do
    let(:values) { ['Some description', 'Some description 2'] }
    it { expect(serializer.description).to eql ['Some description', 'Some description 2'] }
  end
end
