module API
  module Inbound
    class InboundMessageService
      def consume_message(message)
        process_message(message)
        API::Response.build_response(message.message_id, @batch.inbound_batch_id, @errors)
      rescue StandardError => e
        handle_error(e)
        API::Response.build_error_response(message.message_id, @batch&.inbound_batch_id, e)
      ensure
        @batch.save if @batch.present?
      end

      private

      def process_message(message)
        @errors = []
        create_inbound_batch(message.source, message.data_type)
        save_to_database(message)
        save_to_file(message)
      end

      def create_inbound_batch(source, data_type)
        @batch = ::Inbound::Batch.create!(source: source, data_type: data_type)
      end

      def save_to_database(message)
        # TODO: implement database service
      end

      def save_to_file(message)
        name = [message.source, message.data_type, @batch.inbound_batch_id].join('_')
        API::Inbound::FlatFileService.new.write_to_file(name: name, data: message.raw_data)
      end

      def handle_error(error)
        @batch.mark_error(error.message) if @batch.present?

        interesting_backtrace = error.backtrace.select { |s| s.include? 'item_indexer/app/' }
        Rails.logger.error(([error.message] + interesting_backtrace).join("\n\t"))
      end
    end
  end
end