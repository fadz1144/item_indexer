module Inbound
  module Errors
    class InboundError < StandardError
    end

    class SourceAndDataTypeNotRecognized < InboundError
      def initialize(source, data_type)
        super "Source '#{source}' and data type '#{data_type}' were not recognized"
      end
    end
  end
end
