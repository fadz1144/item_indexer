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

      num_chunks = calculate_num_chunks(set_size)
      queue_work(chunk_size, num_chunks, num_threads, set_size)
      benchmark(num_records: num_chunks * set_size, t0: @start_time, prefix: 'ALL WORKERS')

      logger.info 'Indexing DONE'
    rescue SignalException
      # when we die, take our children with us
      cleanup_on_terminate
      logger.error "\nExited, killing all forked children."
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      ids = @indexer.fetch_ids_relation.limit(limit).offset(offset).ids
      ids.each_slice(chunk_size).with_index do |id_chunk, i|
        handle_publish_chunk(chunk_size, i, limit, offset, id_chunk)
      end
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

    def benchmark(num_records:, t0:, prefix: '', t1: Time.current)
      elapsed = (t1 - t0) * 1000
      logger.info "#{prefix} #{num_records} records in #{elapsed} ms -> Avg: #{elapsed / (1.0 * num_records)} ms"
    end

    def handle_publish_chunk(chunk_size, i, limit, offset, ids)
      logger.info "Indexing #{offset / limit}.#{i}"
      publish_to_search_by_ids(ids, chunk_size)
      @total_num_processed += ids.size

      benchmark(num_records: @total_num_processed, t0: @start_time, prefix: "#{offset / limit}.#{i}") if i % 10 == 9
    end

    def index_hash_for_item(item)
      { index: { _index: index_root, _type: @indexer.index_type, _id: item.id, data: @indexer.raw_json(item) } }
    end
  end
end
