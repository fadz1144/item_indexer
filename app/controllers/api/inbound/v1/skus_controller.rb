module API
  module Inbound
    module V1
      class SkusController < API::APIController
        def batch
          process_batch(:sku)
        end
      end
    end
  end
end
