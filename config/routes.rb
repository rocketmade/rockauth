Rockauth::Engine.routes.draw do
  post :authentications, controller: 'rockauth/authentications', action: 'authenticate'
  resource :me, only: [:show, :create, :update, :destroy], controller: 'rockauth/me'
end
