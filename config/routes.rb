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

  root to: 'health_check#version'
  get 'version' => 'health_check#version'

  resources :health_check, only: [:index]
end
