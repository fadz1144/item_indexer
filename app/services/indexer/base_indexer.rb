require 'background_task_manager'
module Indexer
  class BaseIndexer
    include BackgroundTaskManager
    attr_accessor :logger

    def initialize(logger: Rails.logger)
      @logger              = logger
      @total_num_processed = 0
      @start_time          = Time.current
    end

    def publish_to_search_by_ids(ids, chunk_size = 1_000)
      results = []
      ids = [ids] unless ids.is_a? Array
      ids.each_slice(chunk_size) do |id_chunk|
        skus   = objects_by_ids(id_chunk)
        json   = each_chunk(skus)
        result = client.bulk body: json
        results << result
      end
      # TODO: check for errors??
      results
    end

    def determine_count
      raise 'Subclass must implement determine_count'
    end

    def index_root
      ENV['INDEX_NAME'] || 'catalog'
    end

    def index_type
      raise 'Subclass must implement index_type'
    end

    def publish_to_search(_limit = 100_000, _offset = 0, _chunk_size = 1_000)
      raise 'Subclass must implement publish_to_search'
    end

    def id_for_item(_item)
      raise 'Subclass must implement id_for_item'
    end

    def raw_json(_item)
      raise 'Subclass must implement raw_json'
    end

    def objects_by_ids(_ids)
      raise 'Subclass must implement objects_by_ids'
    end

    def client
      @client ||= ES::ESClient.new
    end

    def perform(set_size = 10_000, chunk_size = 1_000, num_threads = 4)
      logger.info "ES Client initialized: #{client}"

      count = determine_count

      num_chunks = (count / set_size) + 1

      queue_work(chunk_size, num_chunks, num_threads, set_size)

      benchmark(num_records: num_chunks * set_size, t0: @start_time, prefix: 'ALL WORKERS')
    rescue SignalException
      # when we die, take our children with us
      cleanup_on_terminate
      logger.error "\nExited, killing all forked children."
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

    def each_chunk(items)
      items.each_with_object([]) do |item, arr|
        arr << { index: { _index: index_root, _type: index_type, _id: id_for_item(item), data: raw_json(item) } }
      end
    end

    private

    def queue_work(chunk_size, num_chunks, num_threads, set_size)
      work_queues = []
      (0..num_threads).each { |thread_index| work_queues[thread_index] = [] }
      (0..num_chunks).each { |chunk_index| work_queues[chunk_index % num_threads] << chunk_index }

      work_queues.each_with_index do |work_q, worker_index|
        run_in_background { handle_chunk_q(chunk_size, set_size, work_q, worker_index) }
      end
      wait_for_background_tasks
    end

    def handle_chunk_q(chunk_size, set_size, work_q, worker_index)
      logger.info "#{worker_index} => STARTED!"
      process_work_q(chunk_size, set_size, work_q, worker_index)
      logger.info "#{worker_index} => DONE!"
    end

    def process_work_q(chunk_size, set_size, work_q, worker_index)
      until work_q.empty?
        index = work_q.pop
        begin
          publish_to_search(set_size, index * set_size, chunk_size)
        rescue => e
          logger.error "problem on index #{worker_index}\n#{e.inspect}"
          logger.error e.backtrace.join("\n")
        end
      end
    end
  end
end
