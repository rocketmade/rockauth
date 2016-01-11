Rockauth::Engine.routes.draw do
  get    :authentications, controller: 'rockauth/authentications', action: 'index'
  post   :authentications, controller: 'rockauth/authentications', action: 'authenticate'
  delete :authentications, controller: 'rockauth/authentications', action: 'destroy'
  delete 'authentications/:id', controller: 'rockauth/authentications', action: 'destroy'

  resource :me, only: [:show, :create, :update, :destroy], controller: 'rockauth/me'
  resources :provider_authentications, controller: 'rockauth/provider_authentications'
  post 'passwords/forgot', controller: 'rockauth/passwords', action: 'forgot'
  post 'passwords/reset', controller: 'rockauth/passwords', action: 'reset'
end
