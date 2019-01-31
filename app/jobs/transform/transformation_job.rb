# this is poorly named, it is the Inbound Transformation Job
module Transform
  class TransformationJob < ApplicationJob
    queue_as :transform

    def perform(source)
      Rails.logger = Logger.new(STDOUT)
      JobLock.new("inbound_transformation_job__#{source}").with_lock do |lock|
        run_service(source, lock)
      end
    end

    private

    def run_service(source, lock)
      Rails.logger.info 'Looking for batches in need of transformation...'
      each_inbound_batch_id(source) do |inbound_batch_id|
        lock.extend
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
