Rails.application.routes.draw do
  post '/', to: 'webhook#callback'
  post '/callback', to: 'webhook#callback'
end
