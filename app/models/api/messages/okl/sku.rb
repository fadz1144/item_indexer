module API
  module Messages
    module OKL
      class Sku < API::Messages::Base
        def self.model_class
          ::Inbound::OKL::SkuRevision
        end

        def item_id
          @data['sku_id']
        end

        def children
          [API::Messages::OKL::SkuShipping.new(child_data('sku_shipping')),
           API::Messages::OKL::SkuDimensions.new(child_data('sku_dimensions')),
           API::Messages::OKL::SkuState.new(child_data('sku_state'))] +
            child_data_array('sku_attributes', API::Messages::OKL::SkuAttribute) +
            child_data_array('images', API::Messages::OKL::SkuImage)
        end

        private

        def child_data(key)
          @data.fetch(key, {}).merge(@data.slice('sku_id'))
        end

        def child_data_array(key, message_class)
          @data[key].map do |attr|
            message_class.new(attr.slice('sku_id'))
          end
        end
      end
    end
  end
end
