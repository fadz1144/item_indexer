module API
  class InboundBatchesController < AuthenticatedController
    def index
      render json: ::Inbound::Batch.order(inbound_batch_id: :desc).limit(1000)
    end
  end
end
