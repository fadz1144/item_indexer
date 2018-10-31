module Transform
  module Transformers
    module XPDM
      # Web Status Rollup
      #
      # Module Web Status Rollup excludes web_status from the attribute mapping, then assigns the rolled up value
      # with an after transform callback.
      #
      # The including transformer must implement method assign_web_status, which assigns the target's web_status
      # by calling web_status_rollup and passing in the concept items (concept products or concept skus).
      module WebStatusRollup
        extend ActiveSupport::Concern
        include Transform::Transformers::ConstantRollupBuilder

        included do
          exclude :web_status
          after_transform :assign_web_status
          define_best_value_rollup_method :web_status, PDM::SystemStatusMapper::ROLLUP_SORT
        end
      end
    end
  end
end
