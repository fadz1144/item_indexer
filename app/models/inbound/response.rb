module Inbound
  class Response
    attr_reader :status

    def self.build_response(message_id, batch_id, item_errors)
      body = if item_errors.present?
               { status: 207, code: :check_item_errors, errors: item_errors }
             else
               { status: 201, code: :created }
             end

      new(body, message_id, batch_id)
    end

    def self.build_error_response(message_id, batch_id, error)
      status = error.is_a?(Inbound::Errors::InboundError) ? 400 : 500
      body = { status: status, code: Rack::Utils::HTTP_STATUS_CODES[status] }

      body[:errors] = error.message if status == 400 || Rails.env.development?
      body[:error_backtrace] = error.backtrace.select { |s| s.include? 'item_indexer/app/' } if Rails.env.development?

      new(body, message_id, batch_id)
    end

    def initialize(body, message_id, batch_id)
      @body = body
      @body.store(:message_id, message_id) unless message_id.nil?
      @body.store(:batch_id, batch_id) unless batch_id.nil?
    end

    def status
      @body[:status]
    end

    def as_json(*)
      @body
    end

    def to_xml(*)
      @body.to_xml(root: 'response', skip_instruct: true, skip_types: true)
    end
  end
end
