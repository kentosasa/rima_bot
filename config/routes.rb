Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  resources :reminds, except: [:index] do
    member do
      get :activate
    end
  end

  resources :groups, only: [:show, :edit, :update] do
    member do
      get :reminds
      get 'reminds/new', to: 'reminds#new'
    end
  end
end
