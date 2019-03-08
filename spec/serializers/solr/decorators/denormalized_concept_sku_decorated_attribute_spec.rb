require 'rails_helper'

RSpec.describe SOLR::Decorators::DenormalizedConceptSkuDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::DenormalizedConceptSkuDecoratedAttribute

      decorate_denormalized_concept_sku 'foo'
      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, decorated_skus_iterator: values))
  end

  context 'multiple, concept-specific fields' do
    value = 'baz'
    let(:values) { [value] }
    it { expect(serializer.baby__foo).to eql value }
    it { expect(serializer.bbby__foo).to eql value }
  end
end
