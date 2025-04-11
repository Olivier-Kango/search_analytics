Rails.application.routes.draw do
  resources :searches, only: [:create]
  get 'analytics', to: 'analytics#index'
end
