require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class AuthenticationsController < ActionController::API
    include ActionController::Serialization

    serialization_scope :view_context

    def authenticate
      @auth_response = Authenticator.from_request(request, self)
      render @auth_response.render
    end

    def authentication_options
      {}
    end

    def resource_owner_class
      Rockauth::Configuration.resource_owner_class
    end
  end
end
