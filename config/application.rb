require_relative 'boot'

require 'rails/all'
require_relative '../lib/env_var_bootstrap'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ItemIndexer
  class Application < Rails::Application
    EnvVarBootstrap.new("#{Rails.root}/.ruby-env") unless Rails.env.production?
    EnvVarBootstrap.new('./.ruby-env.test') if Rails.env.test?
    # custom settings
    config.settings = config_for(:settings)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
