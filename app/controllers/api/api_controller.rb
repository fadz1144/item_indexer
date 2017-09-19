module API
  class APIController < ActionController::API
    VALID_SOURCES = %w[okl].freeze

    private

    # TODO: Create error class
    # the route has a constraint, but it doesn't allow anchors, so double check the source is not OKL-rugs
    def source
      source = params[:source]
      raise "Bad, bad source: #{source}" unless VALID_SOURCES.include?(source)
      source.upcase
    end

    def response_format
      request.format.to_sym || :json
    end
  end
end
