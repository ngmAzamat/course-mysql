Rails.application.routes.draw do
  get "home/index"
  root "home#index"

  post "/send", to: "messages#create"

  get "up" => "rails/health#show", as: :rails_health_check
  mount ActionCable.server => '/cable'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: redirect('/auth/keycloak')
  get '/logout', to: 'sessions#destroy'
end