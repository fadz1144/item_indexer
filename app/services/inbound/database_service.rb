module Inbound
  class DatabaseService
    attr_reader :errors

    def write_message(batch, message)
      @batch = batch
      @errors = {}
      message.transactional_items.each do |item|
        save_item_records(item)
      end
    end

    private

    def save_item_records(item)
      records = item.records
      records.each { |r| r.inbound_batch = @batch }
      records.first.transaction { records.each(&:save!) }
    rescue => e
      @errors[item.item_id] = e.message
      log_error(e, item.class)
    end

    def log_error(error, item_class)
      message = error.message
      message = ([message] + error.backtrace).join("\n\t") unless @errors.size > 5 # don't flood error log
      Rails.logger.error "[#{item_class}] #{message}"
    end
  end
end
