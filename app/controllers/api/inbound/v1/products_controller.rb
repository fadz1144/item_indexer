module API
  module Inbound
    module V1
      class ProductsController < API::APIController
        include API::Inbound::Messages

        def batch
          message = instantiate_message(source, :product, request.request_parameters)
          response = API::Inbound::InboundMessageService.new.consume_message(message)

          render response_format => response, status: response.status
        end
      end
    end
  end
end
