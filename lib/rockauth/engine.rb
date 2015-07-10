
module Rockauth
  class Engine < ::Rails::Engine
    isolate_namespace Rockauth
    initializer "rockauth.inject.controller_concern" do
      ActionController::API.send :include, Rockauth::ControllerConcern
    end
  end
end
