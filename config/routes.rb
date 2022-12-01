Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :collections do
    resources :nfts
    resources :portfolio_collections, only: [:create]
  end
  resources :portfolio_collections, only: [:destroy]
  resources :portfolios, only: [:index]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
end
