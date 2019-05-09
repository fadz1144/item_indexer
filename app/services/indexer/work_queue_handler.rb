require 'background_task_manager'
module Indexer
  class WorkQueueHandler
    include BackgroundTaskManager
    attr_accessor :logger

    def initialize(logger: Rails.logger)
      @logger = logger
    end

    def queue_work(num_chunks, num_threads, set_size, &block)
      work_queues = []
      (0..num_threads).each { |thread_index| work_queues[thread_index] = [] }
      (0..num_chunks).each { |chunk_index| work_queues[chunk_index % num_threads] << chunk_index }

      work_queues.each_with_index do |work_q, worker_index|
        run_in_background { handle_chunk_q(set_size, work_q, worker_index, &block) }
      end
      wait_for_background_tasks
    end

    def handle_chunk_q(set_size, work_q, worker_index, &block)
      logger.info "#{worker_index} => STARTED!"
      process_work_q(set_size, work_q, worker_index, &block)
      logger.info "#{worker_index} => DONE!"
    end

    def process_work_q(set_size, work_q, worker_index)
      until work_q.empty?
        index = work_q.pop
        begin
          yield set_size, index * set_size
        rescue => e
          logger.error "problem on index #{worker_index}\n#{e.inspect}"
          logger.error e.backtrace.join("\n")
        end
      end
    end

    def cleanup
      cleanup_on_terminate
    end
  end
end
