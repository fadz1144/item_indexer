module Transform
  class TransformBatchBuilderService
    def create_transform_batch_for_inbound_batch(inbound_batch_id)
      Transform::Batch.create.tap do |batch|
        assign_transform_to_batch(batch, inbound_batch_id)
      end
    end

    private

    def assign_transform_to_batch(batch, inbound_batch_id)
      Inbound::Batch.transaction do
        ib = Inbound::Batch.lock.find(inbound_batch_id)
        validate_inbound_batch_complete(ib)
        validate_inbound_batch_not_assigned(ib)
        ib.transform_batch = batch
        ib.save!
      end
    rescue => e
      batch.mark_error(e.message)
      batch.save
    end

    def validate_inbound_batch_not_assigned(inbound_batch)
      return if inbound_batch.transform_batch_id.nil?
      raise "Inbound batch #{inbound_batch.id} has already been assigned " \
            "transformation #{inbound_batch.transform_batch_id}"
    end

    def validate_inbound_batch_complete(inbound_batch)
      return if inbound_batch.complete?
      raise "Inbound batch #{inbound_batch.id} status is '#{inbound_batch.status}'; must be complete"
    end
  end
end
