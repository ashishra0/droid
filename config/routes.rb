Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      post 'webhooks/receive', controller: :webhooks, action: :receive
      get 'ping', controller: :ping, action: :index
    end
  end
end
