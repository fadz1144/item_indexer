module Transform
  # = Transformation Service
  #
  # The transformation service processes inbound batches and pushes inserts / updates to the polished tables.
  class TransformationService
    attr_writer :transformer_class

    def transform(inbound_batch_id)
      @batch = Transform::TransformBatchBuilderService.new.create_transform_batch_for_inbound_batch(inbound_batch_id)
      return if @batch.error?

      @batch.execute_and_record_status! { process_inbound_batch }

      submit_reindex_job
    end

    private

    def process_inbound_batch
      transformer_class.source_relation.where(inbound_batch_id: @batch.inbound_batch.id).find_in_batches do |group|
        source_and_target_pairs(group) { |source, target| transform_item(source, target) }
      end
    end

    def source_and_target_pairs(group)
      tc = transformer_class
      target_key = tc.target_match_key
      source_key = tc.source_match_key
      indexed_targets = tc.target_relation.where(target_key => group.map(&source_key)).index_by(&target_key)

      group.each do |source|
        yield(source, indexed_targets.fetch(source.public_send(source_key), tc.target_class.new))
      end
    end

    def transform_item(source, target)
      transformer = transformer_class.new(source)
      transformer.apply_transformation(target)
      save_item(source, target)
    end

    def save_item(source, target)
      if target.valid?
        target.save! if target.changed_for_autosave?
      else
        record_errors(source, target.errors.full_messages)
      end
    rescue StandardError => e
      Rails.logger.error "[#{self.class}] Unexpected error saving item: #{e.message}\n\t#{e.backtrace}"
      record_errors(source, [e.message])
    end

    def record_errors(source, error_messages)
      error_messages.each do |error_message|
        @batch.batch_errors.build(source_item: source, message: error_message)
      end
    end

    # can be derived or injected
    def transformer_class
      @transformer_class ||= determine_transformer_class
    end

    # convention is that these are concept-specific transformations; this means, for example, that if a transformer is
    # needed for ConceptSkuPricing, then it should come in under the data type sku_pricing
    def determine_transformer_class
      source = @batch.inbound_batch.source
      data_type = @batch.inbound_batch.data_type
      "Transform::Transformers::#{source.upcase}::Concept#{data_type.titlecase}".constantize
    end

    def submit_reindex_job
      data_type = @batch.data_type
      important_time = @batch.stop_datetime
      Indexer::ReindexJobFactory.job_for_type(data_type).perform_later(important_time) unless @batch.error?
    end
  end
end
