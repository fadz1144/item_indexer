class HealthCheckController < ApplicationController
  def index
    health = {
      system:         'ok',
      db_host: ENV.fetch('DATABASE_HOST')
    }
    render json: health, content_type: 'application/json'
  end
end
