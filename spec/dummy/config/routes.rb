Rails.application.routes.draw do

  mount Rockauth::Engine => "/rockauth"
end
