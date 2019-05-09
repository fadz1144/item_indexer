module Indexer
  # = Batch Loader
  #
  # Class BatchLoader wraps a complete indexing and yields within an index batch.
  class BatchLoader
    def self.execute_in_batch
      Index::Batch.create.tap do |batch|
        batch.execute_and_record_status! do
          yield batch
        end
      end
    end
  end
end
