module Inbound
  class InboundMessageService
    attr_accessor :database_service, :flat_file_service, :transformation_job

    def initialize(source, data_type)
      @source = source
      @data_type = data_type
    end

    # TODO: build more custom errors for anything the client should be able to resolve
    def consume_message(message)
      create_inbound_batch
      handler = build_handler(message)
      process_message(handler)
      Inbound::Response.build_response(handler.message_id, @batch.inbound_batch_id, @errors)
    rescue StandardError => e
      handle_error(e, handler&.message_id)
      Inbound::Response.build_error_response(handler&.message_id, @batch&.inbound_batch_id, e)
    ensure
      @batch.save if @batch.present?
    end

    private

    def create_inbound_batch
      @batch = ::Inbound::Batch.create!(source: @source, data_type: @data_type)
    end

    # supports either a generic message handler with the class name "Message" or an endpoint-specific handler
    # for example, a generic OKL message is Inbound::MessageHandlers::OKL::Message, while a sku-specifc handler would be
    # Inbound::MessageHandlers::OKL::Sku.
    def build_handler(message)
      handler_class = "#{Inbound::MessageHandlers}::#{@source.upcase}::#{@data_type.upcase}".safe_constantize ||
                      "#{Inbound::MessageHandlers}::#{@source.upcase}::Message".constantize
      handler_class.new(message, @data_type)
    rescue NameError => e
      raise unless e.message.starts_with?('uninitialized constant Inbound::MessageHandlers::')
      raise Inbound::Errors::SourceAndDataTypeNotRecognized.new(@source, @data_type)
    end

    def process_message(handler)
      save_to_database(handler)
      save_to_file(handler)
      @batch.mark_complete
      submit_transformation_job
    end

    def save_to_database(handler)
      service = @database_service || Inbound::DatabaseService.new
      service.write_message(@batch, handler)
      @errors = service.errors
    end

    def save_to_file(handler)
      name = [@source, @data_type, @batch.inbound_batch_id].join('_')
      service = @flat_file_service || Inbound::FlatFileService.new
      service.write_to_file(name: name, data: handler.data)
    end

    def submit_transformation_job
      job = @transformation_job || Transform::TransformationJob
      job.perform_later(@source)
    end

    def handle_error(error, message_id)
      @batch.mark_error(error.message) if @batch.present?

      searchable = "[#{self.class.name}] Error processing batch #{@batch&.inbound_batch_id} (message #{message_id})"
      interesting_backtrace = error.backtrace.select { |s| s.include? 'item_indexer/app/' }
      Rails.logger.error(([searchable, error.message] + interesting_backtrace).join("\n\t"))

      # TODO: honey badger non-Inbound Errors
    end
  end
end
