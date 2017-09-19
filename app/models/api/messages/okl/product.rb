module API
  module Messages
    module OKL
      class Product < API::Messages::Base
        def initialize(message)
          @data = message[:data]
        end
      end
    end
  end
end
