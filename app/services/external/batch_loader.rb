module External
  # = Batch Loader
  #
  # Class BatchLoader wraps an engine creation and yield within a transformation batch. Pass in the transformer class;
  # it yields the engine and returns the batch.
  class BatchLoader
    def self.execute_in_batch(direct_batch, transformer_class)
      Transform::Batch.create(direct_batch: direct_batch).tap do |batch|
        batch.execute_and_record_status! do
          engine = CatalogTransformer::Engine.new(batch, transformer_class)
          yield engine
        end
      end
    end
  end
end
