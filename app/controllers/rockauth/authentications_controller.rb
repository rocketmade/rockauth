require 'rails-api'
module Rockauth
  class AuthenticationsController < ActionController::API
    def authenticate
      Authenticator.from_request(request, self)
    end

    def authentication_options
      {}
    end
  end
end
