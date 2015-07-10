Rockauth::Engine.routes.draw do
  post 'authentications', to: "rockauth/authentications#authenticate"
  resource :me, only: [:show, :create, :update], controller: 'rockauth/me'
end
