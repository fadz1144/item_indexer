module API
  module Messages
    module OKL
      class SkuAttribute < API::Messages::Base
        def records
          sku_id = @data.delete('sku_id')

          @data.map do |code, value|
            ::Inbound::OKL::SkuAttributeRevision.new.tap do |r|
              r.sku_id = sku_id
              r.code = code
              r.value = value
            end
          end
        end
      end
    end
  end
end
