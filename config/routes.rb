# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :price_updates
  resources :cash_dividends do
    member do
      put :update_meta
    end
  end
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

  put :update_prices, to: "dashboard#update_prices"
  root to: 'dashboard#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
