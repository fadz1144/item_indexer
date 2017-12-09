module API
  module Inbound
    module V1
      class ProductsController < API::APIController
        def batch
          process_batch(:product)
        end
      end
    end
  end
end
