require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::OKL::Product do
  let(:source) { Inbound::OKL::ProductRevision.new }
  let(:target) { CatModels::Product.new }
  let(:transformer) { described_class.new(source) }

  it_behaves_like 'valid transformer'

  context 'merch tree nodes' do
    let(:merch_tree) do
      CatModels::Tree.create(tree_id: 2,
                             source_created_at: Time.current,
                             source_updated_at: Time.current)
    end
    let(:dept_tree_node) do
      merch_tree.tree_nodes.create(level: 1, source_code: '123',
                                   source_created_at: Time.current, source_updated_at: Time.current)
    end
    let(:sub_dept_tree_node) do
      merch_tree.tree_nodes.create(level: 2, source_code: '123456',
                                   source_created_at: Time.current, source_updated_at: Time.current)
    end
    let(:class_tree_node) do
      merch_tree.tree_nodes.create(level: 3, source_code: '123456789',
                                   source_created_at: Time.current, source_updated_at: Time.current)
    end

    before do
      source.bbb_department_id = 123
      source.bbb_sub_department_id = 456
      source.bbb_class_id = 789
    end

    context 'assigns' do
      before do
        dept_tree_node
        sub_dept_tree_node
        class_tree_node
        transformer.apply_transformation(target)
      end

      it 'department' do
        expect(target.merch_dept_tree_node).to eq dept_tree_node
      end

      it 'sub dept' do
        expect(source.merch_sub_dept_tree_node).to eq sub_dept_tree_node
      end

      it 'class' do
        expect(target.merch_class_tree_node).to eq class_tree_node
      end
    end
  end
end
