module API
  class InboundBatchesController < ApplicationController
    def index
      render json: ::Inbound::Batch.order(inbound_batch_id: :desc).limit(1000)
    end
  end
end
