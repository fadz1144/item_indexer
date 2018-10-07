module External
  module XPDM
    module MerchandisingTreeNodeAssociations
      extend ActiveSupport::Concern
      SYNTHETIC_KEYS = %i[merch_sub_dept_source merch_class_source].freeze

      included do
        with_options class_name: 'CatModels::TreeNode', optional: true, primary_key: :source_code do
          belongs_to :merch_dept_tree_node, -> { merch_dept }, foreign_key: :mh_dept_cd
          belongs_to :merch_sub_dept_tree_node, -> { merch_sub_dept }, foreign_key: :merch_sub_dept_source
          belongs_to :merch_class_tree_node, -> { merch_class }, foreign_key: :merch_class_source
        end
      end

      def merch_sub_dept_source
        return nil if mh_dept_cd.nil? || mh_sub_dept_cd.nil?
        mh_dept_cd * 1_000 + mh_sub_dept_cd
      end

      def merch_class_source
        return nil if mh_dept_cd.nil? || mh_sub_dept_cd.nil? || mh_class_cd.nil?
        merch_sub_dept_source * 1_000 + mh_class_cd
      end

      # this makes the two synthetic keys appear to be ActiveRecord attributes
      def _read_attribute(attr_name, &block)
        return public_send(attr_name) if SYNTHETIC_KEYS.include?(attr_name.to_sym)
        super
      end

      # the preloader also tries to replace the key, with the source code from the tree node, but it's a no-op
      # see ActiveRecord::Associations::BelongsToAssociation#replace_keys
      def []=(attr_name, value)
        super unless SYNTHETIC_KEYS.include?(attr_name)
      end
    end
  end
end
