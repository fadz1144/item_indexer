require 'rails_helper'

RSpec.describe Inbound::OKL::ProductRevision do
  context 'merch synthetic foreign keys' do
    let(:product) { described_class.new(bbb_department_id: 105, bbb_sub_department_id: 200, bbb_class_id: 300) }

    it('bbb_department_id') { expect(product.bbb_department_id).to eq 105 }
    it('merch_sub_dept_source') { expect(product.merch_sub_dept_source).to eq 105_200 }
    it('merch_class_source') { expect(product.merch_class_source).to eq 105_200_300 }

    context 'preload' do
      let(:merch_tree) do
        CatModels::Tree.create(tree_id: 2,
                               source_created_at: Time.current,
                               source_updated_at: Time.current)
      end
      let(:dept_tree_node) do
        merch_tree.tree_nodes.create(level: 1, source_code: '105',
                                     source_created_at: Time.current, source_updated_at: Time.current)
      end
      let(:sub_dept_tree_node) do
        merch_tree.tree_nodes.create(level: 2, source_code: '105200',
                                     source_created_at: Time.current, source_updated_at: Time.current)
      end
      let(:class_tree_node) do
        merch_tree.tree_nodes.create(level: 3, source_code: '105200300',
                                     source_created_at: Time.current, source_updated_at: Time.current)
      end
      let(:preloader) { ActiveRecord::Associations::Preloader.new }

      it 'merch_dept_tree_node' do
        dept_tree_node
        preloader.preload(product, :merch_dept_tree_node)
        expect(product.merch_dept_tree_node).to eq dept_tree_node
      end

      it 'merch_sub_dept_tree_node' do
        sub_dept_tree_node
        preloader.preload(product, :merch_sub_dept_tree_node)
        expect(product.merch_sub_dept_tree_node).to eq sub_dept_tree_node
      end

      it 'merch_class_tree_node' do
        class_tree_node
        preloader.preload(product, :merch_class_tree_node)
        expect(product.merch_class_tree_node).to eq class_tree_node
      end

      it 'does not fail when ids are nil' do
        preloader = ActiveRecord::Associations::Preloader.new
        expect { preloader.preload(described_class.new, :merch_class_tree_node) }.not_to raise_exception
      end
    end
  end
end
