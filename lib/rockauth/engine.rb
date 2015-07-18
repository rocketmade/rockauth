require 'rails-api'

module Rockauth
  class Engine < ::Rails::Engine
    initializer "rockauth.inject.controller_concern" do
      ActionController::API.send :include, Rockauth::Controllers::Authentication
    end
  end
end
