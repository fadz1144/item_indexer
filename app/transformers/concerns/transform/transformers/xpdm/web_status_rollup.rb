module Transform
  module Transformers
    module XPDM
      # Web Status Rollup
      #
      # Module Web Status Rollup excludes web_status from the attribute mapping, then assigns the rolled up value with
      # an after transform callback.
      #
      # The including transformer must implement method assign_web_status, which assigns the target's web_status
      # by calling web_status_rollup and passing in the concept items (concept products or concept skus).
      module WebStatusRollup
        extend ActiveSupport::Concern

        included do
          exclude :web_status
          after_transform :assign_web_status
        end

        private

        # concept items are either concept skus or concept products
        def web_status_rollup(concept_items)
          if concept_items.any? { |item| item.web_status == CatModels::WebStatus::ACTIVE }
            CatModels::WebStatus::ACTIVE
          elsif concept_items.any? { |item| item.web_status == CatModels::WebStatus::IN_PROGRESS }
            CatModels::WebStatus::IN_PROGRESS
          elsif concept_items.any? { |item| item.web_status == CatModels::WebStatus::SUSPENDED }
            CatModels::WebStatus::SUSPENDED
          else
            CatModels::WebStatus::BUYER_REVIEWED
          end
        end
      end
    end
  end
end
