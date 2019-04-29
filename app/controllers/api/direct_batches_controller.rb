module API
  class DirectBatchesController < AuthenticatedController
    def index
      render json: ::Direct::Batch.order(direct_batch_id: :desc).limit(1000)
    end
  end
end
