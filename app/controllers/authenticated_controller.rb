class AuthenticatedController < ApplicationController
  before_action :redirect_unauthenticated unless Rails.env.development?

  private

  def redirect_unauthenticated
    handle_unauthenticated if user_id_by_jwt.nil?
  end

  def user_id_by_jwt
    auth_cookie_name = ::AuthPlugin::CookieHandler.new.cookie_name
    cookie_data = ::AuthPlugin::Decoder.new.decode(request.cookies[auth_cookie_name])
    (cookie_data&.fetch('user_id', nil)).tap do |user_id|
      Rails.logger.info("  JWT Cookie user ID: #{user_id}")
    end
  rescue ::AuthPlugin::Error => e
    Rails.logger.error e
    nil
  end

  def login_path
    Rails.configuration.settings.fetch('product_catalog_url') + '/login'
  end

  def handle_unauthenticated
    if request.format.json?
      render json: { error: 'not logged in' }, status: :unauthorized
    else
      redirect_to login_path
    end
  end
end
