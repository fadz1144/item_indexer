module Transform
  # = Transformation Service
  #
  # The transformation service processes inbound batches and pushes inserts / updates to the polished tables.
  class TransformationService
    attr_writer :transformer

    def transform(inbound_batch_id)
      @batch = Transform::TransformBatchBuilderService.new.create_transform_batch_for_inbound_batch(inbound_batch_id)
      return if @batch.error?

      @batch.execute_and_record_status! { process_inbound_batch }
    end

    private

    def process_inbound_batch
      engine = CatalogTransformer::Engine.new(@batch, transformer)
      transformer.source_relation.where(inbound_batch_id: @batch.inbound_batch.id).find_in_batches do |source_records|
        engine.transform_items(source_records)
      end
    end

    # can be derived or injected
    def transformer
      @transformer ||= determine_transformer
    end

    # convention is that these are concept-specific transformations; this means, for example, that if a transformer is
    # needed for ConceptSkuPricing, then it should come in under the data type sku_pricing
    def determine_transformer
      source = @batch.inbound_batch.source
      data_type = @batch.inbound_batch.data_type
      "Transform::Transformers::#{source.upcase}::Concept#{data_type.titlecase}".constantize
    end
  end
end
