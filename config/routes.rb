# frozen_string_literal: true

Rails.application.routes.draw do
  resources :stock_dividends
  resources :activities
  resources :companies
  root to: 'application#dashboard'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
