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
            status
          end
        end
      end
    end
  end
end
