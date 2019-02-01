module Transform
  class Batch < ApplicationRecord
    self.primary_key = :transform_batch_id
    with_options foreign_key: :transform_batch_id, primary_key: :transform_batch_id, inverse_of: :transform_batch,
                 dependent: :nullify do
      has_one :inbound_batch, class_name: 'Inbound::Batch'
      has_one :direct_batch, class_name: 'Direct::Batch'
    end

    has_many :batch_errors, class_name: 'Transform::BatchError', foreign_key: :transform_batch_id, autosave: true,
                            inverse_of: :batch, dependent: :destroy, after_add: :save_and_reset_in_batches

    include StringEnums
    string_enum status: %w[in\ progress complete error]
    include ExecutableBatch

    def mark_error(status_reason)
      self.status = STATUS_ERROR
      self.status_reason = status_reason
    end

    def status_reason=(value)
      super(value.truncate(255))
    end

    private

    # when 100 have been added, save and reset; this makes them eligible for garbage collection and gets errors into the
    # database before the end of the process; good for memory, good for visibility
    def save_and_reset_in_batches(_batch_error)
      return if batch_errors.proxy_association.target.size < 100

      save
      batch_errors.reset
    end
  end
end
