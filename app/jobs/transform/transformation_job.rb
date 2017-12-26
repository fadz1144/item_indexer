module Transform
  class TransformationJob < ApplicationJob
    queue_as :transform

    def perform(source)
      lock_name = "#{self.class.name}:#{source}"

      mutex = RedisSimpleMutex.new(lock_name)
      if mutex.lock
        run_service(source)
      else
        Rails.logger.info "Failed to acquire lock for '#{lock_name}'"
      end
    ensure
      mutex.unlock
    end

    private

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
