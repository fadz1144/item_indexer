module Index
  class BatchSerializer < ActiveModel::Serializer
    attributes :index_batch_id, :status, :error_count, :status_reason, :start_datetime, :stop_datetime, :elapsed,
               :elapsed_seconds
    has_many :batch_errors
  end
end
