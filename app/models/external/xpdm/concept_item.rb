module External
  module XPDM
    # = Concept Item
    #
    # Class Concept Item is NOT an active record. The PDM data have multiple tables that make up the concept-level
    # data, so this model stands in for a true active record. As such, it implements a couple of dummy methods that
    # the transformer calls to inspect the model.
    class ConceptItem
      include External::XPDM::Concept
      include PDM::WebFlagsSummarizer
      include External::XPDM::TransformerNonActiveRecordModel

      attr_reader :parent

      delegate :web_site_cd, :web_offer_ind, :web_dsable_ind, :web_offer_dt, to: :@state
      delegate :blck_status_ind, :web_enable_dt, :web_status_flg, to: :@web_info_site, allow_nil: true
      delegate :mstr_prod_desc, :mstr_shrt_desc, :mstr_web_desc, :prod_desc, :vdr_web_prod_desc,
               to: :@description, allow_nil: true
      delegate :concept_vendor, :concept_brand, :source_created_by, :source_created_at, :source_updated_by, to: :parent

      def self.from_parent(parent)
        associations = parent_associations.each_with_object({}) do |name, memo|
          memo[name.singularize] = parent.public_send(name).index_by(&:web_site_cd)
        end

        parent.states.map do |state|
          concept_associations = associations.transform_values { |value| value[state.web_site_cd] }
          new(parent, state, concept_associations)
        end
      end

      def initialize(parent, state, additional_associations)
        @parent = parent
        @state = state
        @description = parent.concept_description(web_site_cd)

        additional_associations.each do |name, value|
          instance_variable_set("@#{name}", value)
        end
      end

      def web_status
        PDM::SystemStatusMapper.value(web_status_flg)
      end

      def site_navigation
        parent.public_send("#{web_site_cd.downcase}_site_navigation")
      end

      def site_nav_tree_node
        site_navigation&.site_nav_tree_node
      end

      def source_updated_at
        [@state, @description, site_navigation].compact.map(&:source_updated_at).compact.max
      end
    end
  end
end
