module API
  class Response
    attr_reader :status

    def self.build_response(message_id, batch_id, item_errors)
      body = if item_errors.present?
               { status: 207, code: :check_item_errors, errors: item_errors }
             else
               { status: 200, code: :success }
             end

      new(:success, body.merge(message_id: message_id, batch_id: batch_id))
    end

    def self.build_error_response(message_id, batch_id, error)
      body = { status: 500, code: :internal_server_error, errors: "Unable to process message #{message_id}" }
      body.store(:message_id, message_id) unless message_id.nil?
      body.store(:batch_id, batch_id) unless batch_id.nil?

      if Rails.env.development?
        body[:error_message] = error.message
        body[:error_backtrace] = error.backtrace.select { |s| s.include? 'item_indexer/app/' }
      end
      new(:error, body)
    end

    def initialize(root_name, body)
      @root_name = root_name
      @body = body
    end

    def status
      @body[:status]
    end

    def as_json(*)
      { @root_name => @body }
    end

    def to_xml(*)
      @body.to_xml(root: @root_name, skip_instruct: true, skip_types: true)
    end
  end
end
