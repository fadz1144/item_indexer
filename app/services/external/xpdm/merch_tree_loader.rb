module External
  module XPDM
    class MerchTreeLoader
      def self.perform
        new(CatModels::Tree.find(2)).load
      end

      def initialize(tree = nil)
        @tree = tree || CatModels::Tree.new(name: 'Merchandising Hierarchy', source_created_at: Time.zone.now,
                                            source_updated_at: Time.zone.now)
      end

      def load
        External::XPDM::MerchTreeView.ordered.each do |node|
          build_dept(node)
          build_sub_dept(node)
          build_class(node)
        end

        @tree.save!
      end

      private

      def build_dept(node)
        return if node.dept_cd.to_s == @current_dept&.source_code

        @current_dept = build(node,
                              name: format_name(node.dept_name),
                              level: 1,
                              source_code: node.dept_cd,
                              leaf: false)
      end

      def build_sub_dept(node)
        return if node.full_sub_dept_cd.to_s == @current_sub_dept&.source_code

        @current_sub_dept = build(node,
                                  name: format_name(node.sub_dept_name),
                                  level: 2,
                                  source_code: node.full_sub_dept_cd,
                                  parent: @current_dept,
                                  leaf: false)
      end

      def build_class(node)
        build(node,
              name: format_name(node.class_name),
              level: 3,
              source_code: node.full_class_cd,
              parent: @current_sub_dept,
              leaf: true)
      end

      def build(node, attributes)
        @tree.tree_nodes.build(attributes.merge(source_created_at: node.source_created_at,
                                                source_updated_at: node.source_updated_at))
      end

      def format_name(value)
        value.force_encoding('iso8859-1').encode('utf-8') if value.present?
      end
    end
  end
end
