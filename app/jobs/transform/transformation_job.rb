module Transform
  class TransformationJob < ApplicationJob
    queue_as :transform

    def perform(source)
      Rails.logger = Logger.new(STDOUT)
      lock_name = "#{self.class.name}:#{source}"
      with_lock(lock_name) { run_service(source) }
    end

    private

    # rubocop:disable Metrics/MethodLength
    def with_lock(lock_name)
      mutex = RedisSimpleMutex.new(lock_name)
      lock_acquired = false

      if mutex.lock
        lock_acquired = true
        Rails.logger.info "Got the '%s' lock, ready to go!" % lock_name
        yield
      else
        Rails.logger.info "Failed to acquire lock for '#{lock_name}'"
      end
    ensure
      mutex.unlock if lock_acquired
    end
    # rubocop:enable Metrics/MethodLength

    def run_service(source)
      Rails.logger.info 'Looking for batches in need of transformation...'
      each_inbound_batch_id(source) do |inbound_batch_id|
        Rails.logger.info "Transforming inbound batch ID: #{inbound_batch_id}"
        Transform::TransformationService.new.transform(inbound_batch_id)
      end
      Rails.logger.info 'Completed all the above transformations.'
    end

    def each_inbound_batch_id(source)
      relation = Inbound::Batch.ready_for_transformation.where(source: source).order(:inbound_batch_id)
      Rails.logger.info("There are #{relation.length} batches to transform.")
      loop do
        id = relation.reload.first&.inbound_batch_id
        break if id.nil?
        yield id
      end
    end
  end
end
