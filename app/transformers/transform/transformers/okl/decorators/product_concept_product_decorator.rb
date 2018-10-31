module Transform
  module Transformers
    module OKL
      module Decorators
        module ProductConceptProductDecorator
          def active
            status == 'ACTIVE'
          end

          def web_status
            if active
              CatModels::Constants::SystemStatus::ACTIVE
            else
              CatModels::Constants::SystemStatus::INACTIVE
            end
          end

          def web_flags_summary
            if active
              CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
            else
              CatModels::Constants::WebFlagsSummary::SUSPENDED
            end
          end
        end
      end
    end
  end
end
