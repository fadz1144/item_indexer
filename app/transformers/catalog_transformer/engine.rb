module CatalogTransformer
  # = Catalog Transformer Engine
  #
  # The Engine class transforms source data into target records. There are two entry points:
  # - use transform_items with a batch of source records to let the engine load existing target data
  # - use transform_item to supply both the source record and the target record
  #
  # Errors will be recorded to the transform batch. The engine does NOT manage the status on the transform batch.
  class Engine
    def initialize(batch, transformer_class)
      @batch = batch
      @transformer_class = transformer_class
    end

    def transform_items(source_records)
      source_key = @transformer_class.source_match_key
      indexed_targets = @transformer_class.load_indexed_targets(source_records)
      source_records.each do |source|
        transform_item(source,
                       indexed_targets.fetch(source.public_send(source_key), @transformer_class.target_class.new))
      end
    end

    def transform_item(source, target)
      transformer = @transformer_class.new(source)
      transformer.apply_transformation(target)
      save_item(source, target)
    end

    private

    def save_item(source, target)
      if target.valid?
        target.save! if target.changed_for_autosave?
      else
        record_errors(source, target.errors.full_messages)
      end
    rescue => e
      Rails.logger.error "[#{self.class}] Unexpected error saving item: #{e.message}\n\t#{e.backtrace}"
      record_errors(source, [e.message])
    end

    def record_errors(source, error_messages)
      error_messages.each do |error_message|
        @batch.batch_errors.build(source_item: source, message: error_message)
      end
    end
  end
end
