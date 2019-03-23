module Transform
  class BatchSerializer < ActiveModel::Serializer
    attributes :transform_batch_id, :status, :status_reason, :start_datetime, :stop_datetime
    has_many :batch_errors
  end
end
