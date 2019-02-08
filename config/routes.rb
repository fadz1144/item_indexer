#
#     $$\   $$\  $$$$$$\ $$$$$$$$\ $$$$$$$$\
#     $$$\  $$ |$$  __$$\\__$$  __|$$  _____|
#     $$$$\ $$ |$$ /  $$ |  $$ |   $$ |
#     $$ $$\$$ |$$ |  $$ |  $$ |   $$$$$\
#     $$ \$$$$ |$$ |  $$ |  $$ |   $$  __|
#     $$ |\$$$ |$$ |  $$ |  $$ |   $$ |
#     $$ | \$$ | $$$$$$  |  $$ |   $$$$$$$$\
#     \__|  \__| \______/   \__|   \________|
#
#     Routes are all going to be effectively prepended with the subdirectory path
#       given in ENV['RAILS_RELATIVE_URL_ROOT'] - see config.ru and server.sh
#       for the mechanism used. This is so that asset URLs will also get this
#       prefix, so that this can serve an app from the subdir on the ELB.
#
Rails.application.routes.draw do
  namespace :api do
    scope module: :inbound do
      scope module: :v1 do
        %w[products skus brands categories].each do |type|
          post ":source/#{type}", to: "#{type}#batch"
        end
      end
    end
  end

  resources :products, only: [:show]

  root to: 'health_check#version'
  get 'version' => 'health_check#version'

  resources :health_check, only: [:index]
end
