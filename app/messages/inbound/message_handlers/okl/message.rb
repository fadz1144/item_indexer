module Inbound
  module MessageHandlers
    module OKL
      # = API MessageHandlers OKL Message
      #
      # The OKL message handler expects the message data to include nodes 'message_id' and 'data'.
      class Message
        attr_reader :data

        def initialize(message, data_type)
          @data = message
          @item_class = "#{Inbound::Messages::OKL}::#{data_type.to_s.titlecase}".constantize
        end

        def message_id
          @data['message_id']
        end

        def transactional_items
          @data['data'].map { |item| @item_class.new(item) }
        end
      end
    end
  end
end
