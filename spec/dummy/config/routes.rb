Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  rockauth 'Rockauth::User'
  rockauth_warden 'Rockauth::User'
end
