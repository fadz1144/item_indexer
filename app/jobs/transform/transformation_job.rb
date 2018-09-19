module Transform
  class TransformationJob < ApplicationJob
    queue_as :transform

    def perform(source)
      lock_name = "#{self.class.name}:#{source}"
      with_lock(lock_name) { run_service(source) }
    end

    private

    def with_lock(lock_name)
      mutex = RedisSimpleMutex.new(lock_name)
      lock_acquired = false

      if mutex.lock
        lock_acquired = true
        yield
      else
        Rails.logger.info "Failed to acquire lock for '#{lock_name}'"
      end
    ensure
      mutex.unlock if lock_acquired
    end

    def run_service(source)
      each_inbound_batch_id(source) do |inbound_batch_id|
        Transform::TransformationService.new.transform(inbound_batch_id)
      end
    end

    def each_inbound_batch_id(source)
      relation = Inbound::Batch.ready_for_transformation.where(source: source).order(:inbound_batch_id)
      loop do
        id = relation.reload.first&.inbound_batch_id
        break if id.nil?
        yield id
      end
    end
  end
end
