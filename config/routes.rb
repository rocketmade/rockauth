Rockauth::Engine.routes.draw do
  get    :authentications, controller: 'rockauth/authentications', action: 'index'
  post   :authentications, controller: 'rockauth/authentications', action: 'authenticate'
  delete :authentications, controller: 'rockauth/authentications', action: 'destroy'
  delete 'authentications/:id', controller: 'rockauth/authentications', action: 'destroy'

  resource :me, only: [:show, :create, :update, :destroy], controller: 'rockauth/me'
end
