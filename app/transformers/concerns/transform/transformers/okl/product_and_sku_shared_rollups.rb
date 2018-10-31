module Transform
  module Transformers
    module OKL
      #= Product and Sku Shared Rollups
      #
      # Module ProductAndSkuSharedRollups has logic used by both the Product and Sku OKL transformers. Each transformer
      # must implement method other_concept_items to return the non-OKL Concept Products or Concept Skus.
      module ProductAndSkuSharedRollups
        extend ActiveSupport::Concern
        include Transform::Transformers::XPDM::WebFlagsSummaryRollup
        include Transform::Transformers::XPDM::WebStatusRollup

        included do
          exclude :web_flags_summary, :web_status
        end

        def assign_web_flags_summary(target)
          return if target.web_flags_summary == @source.web_flags_summary
          target.web_flags_summary = determine_web_flags_summary(@source.web_flags_summary, target)
        end

        def assign_web_status(target)
          return if target.web_status == @source.web_status
          target.web_status = determine_web_status(@source.web_status, target)
        end

        private

        def determine_web_flags_summary(new_value, target)
          if can_set_rollup_without_checking_other_values?(new_value, target.web_flags_summary,
                                                           CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE)
            new_value
          else
            web_flags_summary_rollup([new_value] + other_concept_items.map(&:web_flags_summary))
          end
        end

        def determine_web_status(new_value, target)
          if can_set_rollup_without_checking_other_values?(new_value, target.web_status,
                                                           CatModels::Constants::SystemStatus::ACTIVE)
            new_value
          else
            web_status_rollup([new_value] + other_concept_items.map(&:web_status))
          end
        end

        def can_set_rollup_without_checking_other_values?(new_value_from_source, current_target_value, best_value)
          current_target_value.blank? ||
            new_value_from_source == best_value ||
            other_concept_items.empty?
        end
      end
    end
  end
end
