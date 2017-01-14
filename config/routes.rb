Rails.application.routes.draw do
  get 'reminds/index'

  get 'reminds/new'

  get 'reminds/create'

  get 'reminds/update'

  get 'reminds/edit'

  get 'reminds/destroy'

  post '/', to: 'webhook#callback'
  post '/callback', to: 'webhook#callback'
end
