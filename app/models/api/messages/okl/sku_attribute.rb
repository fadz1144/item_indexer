module API
  module Messages
    module OKL
      class SkuAttribute < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuAttributeRevision
        end
      end
    end
  end
end
