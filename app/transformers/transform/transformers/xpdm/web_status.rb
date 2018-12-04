module Transform
  module Transformers
    module XPDM
      class WebStatus < CatalogTransformer::Base
        include Transform::Transformers::ConstantRollupBuilder
        CONCEPT_IDS = [1, 2, 4].freeze
        define_best_value_rollup_method :web_status, PDM::SystemStatusMapper::ROLLUP_SORT

        def initialize(source)
          @status_by_concept =
            source.web_info_sites
                  .each { |s| s.extend(External::XPDM::Concept) }
                  .each_with_object({}) do |s, memo|
                    memo[s.concept_id] = PDM::SystemStatusMapper.value(s.web_status_flg)
                  end
        end

        def apply_transformation(target)
          target.concept_children
                .select { |c| CONCEPT_IDS.include? c.concept_id }
                .each { |c| c.web_status = @status_by_concept[c.concept_id] }

          target.web_status = web_status_rollup(target.concept_children)
        end
      end
    end
  end
end
