Rails.application.routes.draw do
  get "home/index"
  root "home#index"

  post "/send", to: "messages#create"

  get "up" => "rails/health#show", as: :rails_health_check
end