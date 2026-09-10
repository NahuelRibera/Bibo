Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :products, only: [:index, :show], param: :slug
  resources :categories, only: [:index, :show], param: :slug

  resource :cart, only: [:show]
  resources :cart_items, only: [:create, :update, :destroy]

  resource :wishlist, only: [:show]
  resources :wishlist_items, only: [:create, :destroy]

  resource :checkout, only: [:create]
  get "checkout/success", to: "checkouts#success", as: :checkout_success
  get "checkout/cancel", to: "checkouts#cancel", as: :checkout_cancel
  resources :orders, only: [:show], param: :token

  post "webhooks/stripe", to: "stripe_webhooks#create"

  get "about", to: "pages#about"
  get "account", to: "pages#account"
end
