module Indexer
  class ProductIndexer
    attr_accessor :logger

    def initialize(logger: Rails.logger)
      @logger              = logger
      @children            = []
      @total_num_processed = 0
      @start_time          = Time.now
    end

    INDEX              = ENV['INDEX_NAME'] || 'catalog'
    PRODUCT_INDEX_TYPE = ENV['INDEX_TYPE'] || 'product'

    def perform(set_size = 10_000, chunk_size = 1_000, num_threads = 4)
      count = determine_count

      num_chunks = (count / set_size) + 1

      queue_work(chunk_size, num_chunks, num_threads, set_size)

      benchmark(num_records: num_chunks * set_size, t0: @start_time, prefix: 'ALL WORKERS')
      clear_children
    rescue SignalException
      # when we die, take our children with us
      @children.each { |pid| Process.kill('TERM', pid) }
      logger.error "\nExited, killing all forked children."
    end

    # allows us to update just a few products
    def publish_products_to_search(product_ids)
      products = products_for_ids(product_ids)
      json     = each_chunk(products)
      result   = client.bulk body: json
      # TODO: check for errors??
      result
    end

    private

    def queue_work(chunk_size, num_chunks, num_threads, set_size)
      work_queues = []
      (0..num_threads).each { |thread_index| work_queues[thread_index] = [] }
      (0..num_chunks).each { |chunk_index| work_queues[chunk_index % num_threads] << chunk_index }

      work_queues.each_with_index do |work_q, worker_index|
        supervise_pid(fork { handle_chunk_q(chunk_size, set_size, work_q, worker_index) })
      end
      Process.waitall
    end

    def handle_chunk_q(chunk_size, set_size, work_q, worker_index)
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

    def supervise_pid(pid)
      @children.push(pid)
    end

    def clear_children
      @children = []
    end

    def client
      @client ||= ES::ESClient.new
    end

    def publish_to_search(limit = 100_000, offset = 0, chunk_size = 1_000)
      pids = CatModels::Product.joins(:skus).order(:product_id).distinct.limit(limit).offset(offset).pluck(:product_id)
      pids.each_slice(chunk_size).with_index do |product_ids, i|
        handle_publish_chunk(chunk_size, i, limit, offset, product_ids)
      end
    end

    def handle_publish_chunk(chunk_size, i, limit, offset, product_ids)
      logger.info "Indexing #{offset / limit}.#{i}"
      publish_products_to_search(product_ids)
      @total_num_processed += chunk_size

      benchmark(num_records: @total_num_processed, t0: @start_time, prefix: "#{offset / limit}.#{i}") if i % 10 == 9
    end

    def benchmark(num_records:, t0:, prefix: '', t1: Time.now)
      elapsed = (t1 - t0) * 1000
      logger.info "#{prefix} #{num_records} records in #{elapsed} ms -> Avg: #{elapsed / (1.0 * num_records)} ms"
    end

    def products_for_ids(product_ids)
      # BARF
      CatModels::Product.includes(:brand, :category, skus: [:brand, :category, :products,
                                                            concept_skus: %i[concept_brand concept_vendor
                                                                             concept_sku_images concept_sku_pricing
                                                                             concept_sku_dimensions]])
                        .where(product_id: product_ids)
    end

    def each_chunk(products)
      products.each_with_object([]) do |p, arr|
        arr << { index: { _index: INDEX, _type: PRODUCT_INDEX_TYPE, _id: p.product_id, data: raw_product_json(p) } }
      end
    end

    def raw_product_json(product)
      ProductSerializer.new(product).as_json
    end

    def determine_count
      count = if ENV['PRODUCT_COUNT']
                ENV['PRODUCT_COUNT'].to_i
              else
                CatModels::Product.joins(:skus).order(:product_id).distinct.pluck(:product_id).count
              end
      logger.info "Total num products to index: #{count}"
      count
    end
  end
end
