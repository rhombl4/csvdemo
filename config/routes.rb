Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'products', controller: 'products', action: 'index', defaults: {format: :json}
    end
  end
end
