Rails.application.routes.draw do
  post '/callback', to: 'webhook#callback'

  resources :reminds, except: [:index, :new] do
    member do
      post :activate
      post :inactivate
    end
  end

  resources :events, controller: :reminds, type: 'Event', except: [:new, :edit]
  resources :schedules, controller: :reminds, type: 'Schedule', except: [:new, :edit] do
    member do
      get '/answer', to: 'users#new'
      post '/answer', to: 'users#create'
      get '/answer/:user_id/edit', to: 'users#edit', as: 'answer_edit'
      put '/answer/:user_id', to: 'users#update', as: 'answer_update'
    end
  end

  resources :groups, only: [:show, :edit, :update] do
    member do
      get '/reminds/new', to: 'reminds#new'
      post '/reminds/', to: 'reminds#create'
      get '/schedule/new', to: 'reminds#new', type: 'Schedule'
    end
  end
end
