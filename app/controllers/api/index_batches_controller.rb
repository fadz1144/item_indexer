module API
  class IndexBatchesController < ApplicationController
    def index
      render json: Index::Batch.order(index_batch_id: :desc).limit(1000), include: ''
    end

    def show
      render json: Index::Batch.includes(:batch_errors).find(params[:id].to_i)
    end
  end
end
