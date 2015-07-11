require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class AuthenticationsController < ActionController::API
    include ActionController::Serialization
    serialization_scope :view_context

    def authenticate
      Authenticator.from_request(request, self)
      render nothing: true
    end

    def authentication_options
      {}
    end
  end
end
