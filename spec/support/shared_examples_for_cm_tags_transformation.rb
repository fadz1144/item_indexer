RSpec.shared_examples 'transformation includes tags' do
  context 'with two tags' do
    before do
      source.cm_tags.build(cm_tag_free_frm_txt: 'Go')
      source.cm_tags.build(cm_tag_free_frm_txt: 'Bears!')
      transformer.apply_transformation(target)
    end

    it 'builds two tags' do
      expect(target.tags.map(&:tag_value)).to contain_exactly('Go', 'Bears!')
    end
  end
end
