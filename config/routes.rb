Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  resources :reminds
end
