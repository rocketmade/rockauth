Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  namespace :api do
    mount Rockauth::Engine => "/"
  end
end
