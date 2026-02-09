# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :price_updates
  resources :cash_dividends do
    member do
      put :update_meta
    end
  end
  resources :stock_dividends do
    member do
      put :create_buy_activity
    end
  end
  resources :activities do
    member do
      post :convert_planned
    end
  end
  resources :companies do
    member do
      get :last_price
      post :price_update_from_pse
      delete :refetch_announcements
    end
    collection do
      post :price_update_all_from_pse
    end
  end

  resources :dividend_announcements, only: :index do
    member do
      post :create_transaction
      get :converted_announcement
    end
  end

  resources :crypto_currencies, only: %i[index new create show edit update]
  resources :crypto_activities

  put :update_prices, to: "dashboard#update_prices"

  get "/portfolio/stocks", to: "portfolio#stocks"
  get "/portfolio", to: "portfolio#home"
  root to: "portfolio#home"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
