module Indexer
  class IndexPublisher
    attr_accessor :logger

    def initialize(logger: Rails.logger, index_class:)
      @logger              = logger
      @total_num_processed = 0
      @start_time          = Time.current

      @indexer = index_class.new
    end

    def publish_to_search_by_ids(ids, chunk_size = 1_000)
      results = []
      ids     = [ids] unless ids.is_a? Array
      ids.each_slice(chunk_size) do |id_chunk|
        items = @indexer.fetch_items(id_chunk)
        json = items.map { |item| index_hash_for_item(item) }
        result = client.bulk body: json
        results << result
      end
      # TODO: check for errors??
      results
    end

    def perform(set_size = 10_000, chunk_size = 1_000, num_threads = 4)
      logger.info "ES Client initialized: #{client}"

      with_benchmark(prefix: 'Indexing ALL WORKERS', count: @indexer.determine_count, with_summary: true) do
        num_chunks = calculate_num_chunks(set_size)
        queue_work(chunk_size, num_chunks, num_threads, set_size)
      end
    rescue SignalException
      # when we die, take our children with us
      cleanup_on_terminate
      logger.error "\nExited, killing all forked children."
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      ids = @indexer.fetch_ids_relation.limit(limit).offset(offset).ids
      ids.each_slice(chunk_size).with_index do |id_chunk, i|
        with_benchmark(publish_to_search_benchmark_options(i, id_chunk, limit, offset)) do
          publish_to_search_by_ids(id_chunk, chunk_size)
        end

        @total_num_processed += id_chunk.size
      end
    end

    def publish_to_search_benchmark_options(i, id_chunk, limit, offset)
      {
        prefix:       "Indexing #{offset / limit}.#{i}",
        count:        @total_num_processed + id_chunk.size,
        start_time:   @start_time,
        should_print: i % 10 == 9
      }
    end

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

    def with_benchmark(prefix: '', start_time: Time.current, count: nil, should_print: true, with_summary: false)
      logger.info "#{prefix} START" if should_print
      yield
      end_time          = Time.current
      elapsed_ms        = (end_time - start_time) * 1_000
      logger.info benchmark_end_str(prefix, elapsed_ms, count) if should_print
      logger.info benchmark_summary_str(prefix, elapsed_ms) if should_print && with_summary
    end

    def benchmark_end_str(prefix, elapsed_ms, count)
      avg_str = count.present? ? "-> Avg: #{elapsed_ms / (1.0 * count)} ms for #{count} items" : ''
      "#{prefix} DONE took #{elapsed_ms} ms #{avg_str}"
    end

    # Takes elapsed ms and turns it into HH:MM:SS
    def benchmark_summary_str(prefix, elapsed_ms)
      summary_time = Time.at(elapsed_ms / 1000).utc.strftime('%H:%M:%S')
      "#{prefix} SUMMARY Elapsed: #{summary_time}"
    end
  end
end
