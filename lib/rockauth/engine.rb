require 'rails-api'

module Rockauth
  class Engine < ::Rails::Engine
    initializer "rockauth.inject.controller_concern" do
      ActionController::API.send :include, Rockauth::Controllers::Authentication
    end

    initializer "rockauth.inject.routing_concern" do
      ActionDispatch::Routing::Mapper.send :include, Rockauth::Routes
    end
  end
end
