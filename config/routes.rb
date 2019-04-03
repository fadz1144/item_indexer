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

    resources :transform_batches, only: [:index, :show], defaults: { format: 'json' }
    resources :inbound_batches, only: [:index], defaults: { format: 'json' }
    resources :index_batches, only: [:index, :show], defaults: { format: 'json' }
    resources :products, only: [:show], defaults: { stream: 'false' }
  end
  get 'products/:id' => 'api/products#show'

  root to: 'spa#index'
  get 'version' => 'health_check#version'

  resources :health_check, only: [:index]

  get 'spa/*xyz' => 'spa#index'
end
