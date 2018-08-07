module Transform
  module Transformers
    module OKL
      module Decorators
        module ProductConceptProductDecorator
          def active
            status == 'ACTIVE'
          end

          def web_status
            active ? 'Active' : 'In Progress'
          end
        end
      end
    end
  end
end
