module Inbound
  module OKL
    module MerchandisingTreeNodeAssociations
      extend ActiveSupport::Concern
      SYNTHETIC_KEYS = %i[merch_sub_dept_source merch_class_source].freeze

      included do
        with_options class_name: 'CatModels::TreeNode', optional: true, primary_key: :source_code do
          belongs_to :merch_dept_tree_node, -> { merch_dept }, foreign_key: :bbb_department_id
          belongs_to :merch_sub_dept_tree_node, -> { merch_sub_dept }, foreign_key: :merch_sub_dept_source
          belongs_to :merch_class_tree_node, -> { merch_class }, foreign_key: :merch_class_source
        end
      end

      def merch_sub_dept_source
        return nil if bbb_department_id.nil? || bbb_sub_department_id.nil?
        bbb_department_id * 1_000 + bbb_sub_department_id
      end

      def merch_class_source
        return nil if bbb_department_id.nil? || bbb_sub_department_id.nil? || bbb_class_id.nil?
        merch_sub_dept_source * 1_000 + bbb_class_id
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
