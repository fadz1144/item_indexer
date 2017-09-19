module API
  module Messages
    module OKL
      class Sku < API::Messages::Base
        def initialize(message)
          @data = message[:data]
        end

        def items
          # TODO: implement me!
        end
      end
    end
  end
end
