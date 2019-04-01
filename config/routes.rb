Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, constraints: { format: :json } do
    namespace :v1 do
      get 'products', controller: 'products', action: 'index'
    end
  end
end
