require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::ConceptProduct,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) do
    External::XPDM::ConceptProduct.new(External::XPDM::Product.new,
                                       External::XPDM::State.new(web_site_cd: 'BBBY'),
                                       description: External::XPDM::Description.new)
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::ConceptProduct.new }
  before { allow(Transform::ConceptCache).to receive(:fetch).and_return(CatModels::Concept.new) }

  it_behaves_like 'valid transformer'

  context 'site navigations' do
    let(:root) { CatModels::TreeNode.new }
    let(:branch) { CatModels::TreeNode.new }
    let(:leaf) { CatModels::TreeNode.new }

    before do
      source.product.bbby_site_navigations.build(root_tree_node: root, branch_tree_node: branch, leaf_tree_node: leaf)
      transformer.apply_transformation(target)
    end

    it 'builds site navigation' do
      expect(source.site_navigations.size).to eq 1
    end

    it 'populates root' do
      expect(source.site_navigations.first.root_tree_node).to be root
    end

    it 'populates branch' do
      expect(source.site_navigations.first.branch_tree_node).to be branch
    end

    it 'populates leaf' do
      expect(source.site_navigations.first.leaf_tree_node).to be leaf
    end
  end
end
