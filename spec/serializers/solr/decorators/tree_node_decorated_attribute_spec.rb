require 'rails_helper'

RSpec.describe SOLR::Decorators::TreeNodeDecoratedAttribute do
  let(:serializer) do
    Class.new do
      include SOLR::Decorators::TreeNodeDecoratedAttribute

      decorate_tree_node 'eph_tree_node_id', tree: 'eph', field: 'id'

      attr_reader :service

      def initialize(service)
        @service = service
      end
    end.new(instance_double(Serializers::DecoratedSkusSerializerService, tree_node_values: values))
  end

  let(:values) { [100, 110, 111] }
  it { expect(serializer.eph_tree_node_id).to eq [100, 110, 111] }
end
