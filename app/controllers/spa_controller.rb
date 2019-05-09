class SpaController < AuthenticatedController
  SPA_INDEX = 'index.html'.freeze

  def index
    format = request.params[:format]
    path = request.path.split('/spa/')&.[](1)
    file = static?(format) ? path : SPA_INDEX
    if static?(format)
      redirect_to "/spa/#{path}"
    else
      render file: Rails.public_path.join('spa', file), layout: false
    end
  end

  private

  def static?(format)
    %w[jpg jpeg ico gif png].include?(format)
  end
end
