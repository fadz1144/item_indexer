class HealthCheckController < ApplicationController
  def index
    health = {
      system: 'ok',
      db_host: ENV.fetch('DATABASE_HOST'),
      solr_endpoint: ENV.fetch('SOLR_ENDPOINT')
    }.merge(ci_info)
    render json: health, content_type: 'application/json'
  end

  def version
    render plain: "Item Indexer v.#{ENV['BBB_CI_VERSION']}"
  end

  private

  def ci_info
    {
      ci_version: ENV['BBB_CI_VERSION'],
      ci_commit: ENV['BBB_COMMIT_SHA']
    }
  end
end
