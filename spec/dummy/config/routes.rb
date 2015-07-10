Rails.application.routes.draw do
  namespace :api do
    mount Rockauth::Engine => "/"
  end
end
