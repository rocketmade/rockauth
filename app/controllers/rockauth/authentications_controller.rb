require 'rails-api'

class Rockauth::AuthenticationsController < ActionController::API
  def authenticate
    Authenticator.from_request(request, self)
  end

  def authentication_options
    {}
  end
end
