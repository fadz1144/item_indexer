Rails.application.routes.draw do
  namespace :api do
    scope module: :inbound do
      scope module: :v1 do
        %w[products skus].each do |type|
          post ":source/#{type}", to: "#{type}#batch", source: Regexp.new(API::APIController::VALID_SOURCES.join('|'))
        end
      end
    end
  end
end
