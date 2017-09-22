module API
  module Messages
    module OKL
      class Product < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::ProductRevision
        end

        def item_id
          @data['product_id']
        end
      end
    end
  end
end
