module Transform
  module Transformers
    module OKL
      module Decorators
        module SkuConceptSkuDecorator
          def status
            if state.obsolete_reason_id.present?
              'Suspended'
            elsif active?
              'Active'
            else
              'In Progress'
            end
          end

          def web_status
            if state.obsolete_reason_id.present?
              # TODO: map reason codes to DROPPED / DISCONTINUED / TO_BE_PURGED
              CatModels::Constants::SystemStatus::DROPPED
            elsif active?
              CatModels::Constants::SystemStatus::ACTIVE
            else
              CatModels::Constants::SystemStatus::INACTIVE
            end
          end

          def web_flags_summary
            if active?
              CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
            elsif state.obsolete_reason_id.nil?
              CatModels::Constants::WebFlagsSummary::IN_WORKFLOW
            else
              CatModels::Constants::WebFlagsSummary::SUSPENDED
            end
          end
        end
      end
    end
  end
end
