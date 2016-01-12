Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  rockauth 'Rockauth::User'
end
