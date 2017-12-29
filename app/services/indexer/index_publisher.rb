require 'benchmark_helper'

module Indexer
  class IndexPublisher
    attr_accessor :logger

    def initialize(logger: Rails.logger, index_class:)
      @logger              = logger
      @total_num_processed = 0
      @start_time          = Time.current

      @indexer   = index_class.new
      @benchmark = BenchmarkHelper.new(logger: logger)
    end

    def publish_to_search_by_ids(ids, chunk_size = 1_000)
      results = []
      ids     = [ids] unless ids.is_a? Array
      ids.each_slice(chunk_size) do |id_chunk|
        items  = @indexer.fetch_items(id_chunk)
        json   = items.map { |item| index_hash_for_item(item) }
        result = client.bulk body: json
        results << result
      end
      # TODO: check for errors??
      results
    end

    def perform(set_size = 10_000, chunk_size = 1_000, num_threads = 4)
      logger.info "ES Client initialized: #{client}"

      worker_benchmark = BenchmarkHelper.new(prefix: 'Indexing ALL WORKERS',
                                             count:  @indexer.determine_count, with_summary: true)
      worker_benchmark.with_benchmark do
        num_chunks = calculate_num_chunks(set_size)
        queue_work(chunk_size, num_chunks, num_threads, set_size)
      end
    rescue SignalException
      # when we die, take our children with us
      cleanup_on_terminate
      logger.error "\nExited, killing all forked children."
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      # this is handy for simulating the work that will be done in an actual publish
      # so I am going to leave it right here
      # mock_publish(limit, offset, chunk_size)

      ids = @indexer.fetch_ids_relation.limit(limit).offset(offset).ids
      ids.each_slice(chunk_size).with_index do |id_chunk, i|
        with_publish_benchmark(i, id_chunk, limit, offset) do
          publish_to_search_by_ids(id_chunk, chunk_size)
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

    def index_root
      'catalog'
    end

    def client
      @client ||= ES::ESClient.new
    end

    def queue_work(chunk_size, num_chunks, num_threads, set_size)
      worker = Indexer::WorkQueueHandler.new(logger: @logger)
      worker.queue_work(num_chunks, num_threads, set_size) do |limit, offset|
        publish_to_search(limit, offset, chunk_size)
      end
    end

    def calculate_num_chunks(set_size)
      count = @indexer.determine_count
      logger.info "Total num items to index: #{count}"
      (count / set_size) + 1
    end

    def index_hash_for_item(item)
      { index: { _index: index_root, _type: @indexer.index_type, _id: item.id, data: @indexer.raw_json(item) } }
    end

    def with_publish_benchmark(i, id_chunk, limit, offset)
      @benchmark.with_benchmark(prefix:       "Indexing #{offset / limit}.#{i}",
                                count:        @total_num_processed + id_chunk.size,
                                start_time:   @start_time,
                                should_print: i % 10 == 9) do
        yield
      end
    end
  end
end
