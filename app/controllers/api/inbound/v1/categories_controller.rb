module API
  module Inbound
    module V1
      class CategoriesController < API::APIController
        def batch
          process_batch(:category)
        end
      end
    end
  end
end
