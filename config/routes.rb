# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :price_updates
  resources :cash_dividends
  resources :stock_dividends
  resources :activities do
    member do
      post :convert_planned
    end
  end
  resources :companies do
    member do
      get :last_price
      post :price_update_from_pse
    end
    collection do
      post :price_update_all_from_pse
    end
  end
  root to: 'dashboard#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
