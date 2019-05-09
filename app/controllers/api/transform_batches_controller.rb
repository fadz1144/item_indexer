module API
  class TransformBatchesController < AuthenticatedController
    def index
      render json: Transform::Batch.order(transform_batch_id: :desc).limit(1000), include: ''
    end

    def show
      render json: Transform::Batch.includes(:batch_errors).find(params[:id].to_i)
    end
  end
end
