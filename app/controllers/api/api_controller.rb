module API
  class APIController < ActionController::API
    private

    def process_batch(data_type)
      service = ::Inbound::InboundMessageService.new(params[:source], data_type)
      response = service.consume_message(request.request_parameters)

      render response_format => response, status: response.status
    end

    def response_format
      request.format.to_sym || :json
    end
  end
end
