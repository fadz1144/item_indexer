module API
  module Messages
    module OKL
      class SkuShipping < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuShippingRevision
        end
      end
    end
  end
end
