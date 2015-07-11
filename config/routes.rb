Rockauth::Engine.routes.draw do
  post 'authentications', to: "rockauth/authentications#authenticate"
  resource :me, only: [:show, :create, :update, :destroy], controller: 'rockauth/me'
end
