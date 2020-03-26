source 'https://rubygems.org'
ruby '~> 2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
git_source(:github_ssh) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "git@github.com:#{repo_name}.git"
end

gem 'cat_models', github_ssh: 'okl/cat_models', branch: 'master', require: true
# gem 'cat_models', path: "../cat_models", require: true

# For interpreting JWT auth tokens from auth_svc
gem 'auth_plugin', git: 'git@github.com:okl/auth_plugin.git', branch: 'master', require: true

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Error reporting
gem 'honeybadger', '~> 3.1'

gem 'rsolr', '~> 2.2'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'string_enums'

gem 'active_model_serializers'
gem 'htmlentities' # some of the PDM data carries tags such as &reg;

gem 'resque'
gem 'resque-scheduler'

# Cloud
gem 'bridge-cloud', github_ssh: 'okl/bridge-cloud', branch: 'master', require: 'bridge/cloud'
# gem 'bridge-cloud', path: '../bridge-cloud', require: 'bridge/cloud'

# oracle gems allow connection to staged PDM data; not required in most cases
group :oracledb do
  gem 'activerecord-oracle_enhanced-adapter', '~> 5.2.6'
  gem 'ruby-oci8', '~> 2.2.7'
end
gem 'composite_primary_keys', '= 11.2.0'

group :sftp do
# Used for the "DW import" flavor of I.I.
  gem 'net-ssh'
  gem 'fun_sftp'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'factory_bot_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0'

  gem 'guard'
  gem 'guard-rspec'
  gem 'rubocop', '= 0.58.2', require: false
  gem 'rubocop-rspec'
  gem 'guard-rubocop'
  gem 'debase'  # I was unable to debug locally without adding this
end

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'fuubar'
  gem 'rspec_junit_formatter'
  gem 'rubocop-junit-formatter'
  gem 'simplecov', :require => false, :group => :test
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
