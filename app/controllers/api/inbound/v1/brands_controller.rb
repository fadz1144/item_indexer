module API
  module Inbound
    module V1
      class BrandsController < API::APIController
        def batch
          process_batch(:brand)
        end
      end
    end
  end
end
