Rockauth::Engine.routes.draw do
  post 'authentications', to: "authentications#authenticate"
end
