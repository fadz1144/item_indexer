require 'benchmark_helper'

module Indexer
  class IndexPublisher
    DEFAULT_DB_FETCH_SIZE = 10_000
    DEFAULT_INDEX_BATCH_SIZE = 1_000
    DEFAULT_NUM_PROCESSES = 4

    attr_accessor :logger, :client

    def initialize(core: 'product', logger: Rails.logger, indexer:, precache: true)
      @logger              = logger
      @total_num_processed = 0
      @start_time          = Time.current

      @indexer   = indexer
      @benchmark = BenchmarkHelper.new(logger: logger)
      @client = SOLR::SOLRClient.new(core)
      @batch = nil
      @workers = []

      # tree cache must be precached
      Indexer::TreeCache.build

      # concept collection cache works with or without optional precaching
      Indexer::ConceptCollectionCache.build if precache
    end

    def publish_to_search_by_ids(ids, chunk_size = 1_000)
      items_to_errors = {}
      ids = [ids] unless ids.is_a? Array
      ids.each_slice(chunk_size) do |id_chunk|
        items = @indexer.fetch_items(id_chunk)
        chunk_items_to_errors = client.publish_items(@indexer, items)
        items_to_errors.merge!(chunk_items_to_errors)
      end
      items_to_errors
    end

    def preview(id)
      items = @indexer.fetch_items([id])
      begin
        client.items_to_documents(@indexer, items, false)
      rescue => e
        e
      end
    end

    # set_size = DB Fetch. chunk_size = size of batch to load to search index
    def perform(set_size = DEFAULT_DB_FETCH_SIZE,
                chunk_size = DEFAULT_INDEX_BATCH_SIZE,
                num_threads = DEFAULT_NUM_PROCESSES)
      Indexer::BatchLoader.execute_in_batch do |batch|
        @batch = batch
        logger.info "Client init: #{client} set_size: #{set_size}, chunk_size: #{chunk_size}, threads: #{num_threads}"
        perform_benchmarked(set_size, chunk_size, num_threads)
      rescue SignalException => e
        cleanup_on_terminate
        raise "signal exception: #{e.message}"
      end
      logger.info("Indexing finished in #{@batch.elapsed}") if @batch.elapsed.present?
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      # this is handy for simulating the work that will be done in an actual publish
      # so I am going to leave it right here
      # mock_publish(limit, offset, chunk_size)

      ids = @indexer.fetch_ids_relation.limit(limit).offset(offset).ids
      ids.each_slice(chunk_size).with_index do |id_chunk, i|
        with_publish_benchmark(i, id_chunk, limit, offset) do
          record_errors(publish_to_search_by_ids(id_chunk, chunk_size))
        end

        @total_num_processed += id_chunk.size
      end
    end

    # def mock_publish(limit, offset, chunk_size)
    #   num_chunks = limit / chunk_size
    #   (0..num_chunks).each do |index|
    #     first_index = offset + (chunk_size * index)
    #     last_index  = first_index + chunk_size - 1
    #     with_publish_benchmark(index, (first_index..last_index), limit, offset) do
    #       sleep 1
    #       print '.'
    #       @total_num_processed += chunk_size
    #     end
    #   end
    # end

    private

    def perform_benchmarked(set_size, chunk_size, num_threads)
      worker_benchmark = BenchmarkHelper.new(prefix: 'Indexing ALL WORKERS',
                                             count:  @indexer.determine_count, with_summary: true)
      worker_benchmark.with_benchmark do
        num_chunks = calculate_num_chunks(set_size)
        queue_work(chunk_size, num_chunks, num_threads, set_size)
      end
    end

    def queue_work(chunk_size, num_chunks, num_threads, set_size)
      worker = Indexer::WorkQueueHandler.new(logger: @logger)
      @workers << worker
      worker.queue_work(num_chunks, num_threads, set_size) do |limit, offset|
        publish_to_search(limit, offset, chunk_size)
      end
    end

    def calculate_num_chunks(set_size)
      count = @indexer.determine_count
      logger.info "Total num items to index: #{count}"
      (count / set_size) + 1
    end

    def with_publish_benchmark(iterator, id_chunk, limit, offset)
      @benchmark.with_benchmark(prefix:       "Indexing #{offset / limit}.#{iterator}",
                                count:        @total_num_processed + id_chunk.size,
                                start_time:   @start_time,
                                should_print: iterator % 10 == 9) do
        yield
      end
    end

    def record_errors(items_to_errors)
      items_to_errors.each { |item, error| @batch.batch_errors.create(indexed_item: item, message: error[:message]) }
    end

    def cleanup_on_terminate
      logger.error "\nExited, killing all forked children."
      logger.error "#{@workers.count} workers to terminate"
      @workers.each(&:cleanup)
    end
  end
end
