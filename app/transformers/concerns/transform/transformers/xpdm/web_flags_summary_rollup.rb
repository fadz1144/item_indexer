module Transform
  module Transformers
    module XPDM
      # Web Flags Summary Rollup
      #
      # Module Web Flags Summary Rollup excludes web_flags_summary from the attribute mapping, then assigns the rolled
      # up value with an after transform callback.
      #
      # The including transformer must implement method assign_web_flags_summary, which assigns the target's
      # web_flags_summary by calling web_flags_summary_rollup and passing in the concept items (concept products or
      # concept skus).
      module WebFlagsSummaryRollup
        extend ActiveSupport::Concern
        include Transform::Transformers::ConstantRollupBuilder

        included do
          exclude :web_flags_summary
          after_transform :assign_web_flags_summary
          define_best_value_rollup_method :web_flags_summary,
                                          [CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE,
                                           CatModels::Constants::WebFlagsSummary::IN_WORKFLOW,
                                           CatModels::Constants::WebFlagsSummary::SUSPENDED,
                                           CatModels::Constants::WebFlagsSummary::BUYER_REVIEWED]
        end
      end
    end
  end
end
