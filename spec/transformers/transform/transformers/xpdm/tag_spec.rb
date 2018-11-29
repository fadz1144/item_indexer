require 'rails_helper'
require 'support/transformer_examples'

RSpec.describe Transform::Transformers::XPDM::Tag,
               skip: !Rails.configuration.settings['enable_pdm_connection'] do
  let(:source) do
    External::XPDM::CMTag.new(cm_tag_free_frm_txt: 'Go Bears!')
  end

  let(:transformer) { described_class.new(source) }
  let(:target) { CatModels::Tag.new }

  it_behaves_like 'valid transformer'

  context '#attribute_values' do
    let(:values) { transformer.attribute_values }

    it 'tag_value' do
      expect(values['tag_value']).to eql 'Go Bears!'
    end
  end
end
