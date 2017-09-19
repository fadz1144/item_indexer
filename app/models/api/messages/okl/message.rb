module API
  module Messages
    module OKL
      class Message
        attr_reader :raw_data, :data_type

        def initialize(message, data_type)
          @raw_data = message
          @data_type = data_type
          @item_class = "#{API::Messages::OKL}::#{data_type.to_s.titlecase}".constantize
        end

        def source
          :okl
        end

        def message_id
          @raw_data[:message_id]
        end

        def items
          @raw_data[:data].map { |item| @item_class.new(item) }
        end
      end
    end
  end
end
