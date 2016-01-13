require 'rails-api'

module Rockauth
  class Engine < ::Rails::Engine
    initializer "rockauth.inject.controller_concern" do
      ActionController::API.send :include, Rockauth::Controllers::Authentication
    end

    initializer "rockauth.inject.routing_concern" do
      ActionDispatch::Routing::Mapper.send :include, Rockauth::Routes
    end

    initializer "rockauth.load_active_admin_resources" do
      if Rockauth::Configuration.generate_active_admin_resources || Rockauth::Configuration.generate_active_admin_resources.nil? && defined?(ActiveAdmin)
        ActiveAdmin.application.load_paths += [File.expand_path(File.join(File.dirname(__FILE__), '../rockauth/admin'))]
      end
    end
  end
end
