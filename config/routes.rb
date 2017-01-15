Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  resources :reminds do
    member do
      get :activate
    end
  end
end
