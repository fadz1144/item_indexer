module API
  module Messages
    module OKL
      class SkuImage < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuImageRevision
        end
      end
    end
  end
end
