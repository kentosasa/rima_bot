Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  resources :reminds, except: [:index, :new] do
    member do
      post :activate
      post :inactivate
    end
  end

  resources :events, controller: :reminds, type: 'Event', except: [:new, :edit]
  resources :schedules, controller: :schedules, type: 'Schedule', except: [:new, :edit]

  resources :groups, only: [:show, :edit, :update] do
    member do
      get '/reminds/new', to: 'reminds#new'
    end
  end
end
