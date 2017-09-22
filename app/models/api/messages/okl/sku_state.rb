module API
  module Messages
    module OKL
      class SkuState < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuStateRevision
        end
      end
    end
  end
end
