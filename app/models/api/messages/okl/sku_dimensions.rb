module API
  module Messages
    module OKL
      class SkuDimensions < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuDimensionsRevision
        end
      end
    end
  end
end
