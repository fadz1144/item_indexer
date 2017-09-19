module API
  module Inbound
    module Messages
      private

      # supports either a generic message handler with the class name "Message" or an endpoint-specific handler
      # for example, a generic OKL message is API::Messages::OKL::Message, while a sku-specifc handler would be
      # API::Messages::OKL::Sku.
      def instantiate_message(source, data_type, message)
        message_class = "#{API::Messages}::#{source}::#{data_type}".safe_constantize ||
                        "#{API::Messages}::#{source}::Message".safe_constantize
        message_class.new(message, data_type)
      end
    end
  end
end
