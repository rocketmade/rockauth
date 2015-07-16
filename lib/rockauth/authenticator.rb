module Rockauth
  class Authenticator
    autoload :Response, 'rockauth/authenticator/response'
    attr_accessor :request
    attr_accessor :controller
    attr_accessor :response

    delegate :params, to: :controller

    def self.authentication_from_request request, controller
      bearer, token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ')
      if bearer.to_s.downcase == "bearer" && token.present?
        Authentication.for_token(token).first
      else
        nil
      end
    end

    def self.from_request request, controller
      instance = new request, controller

      resource_owner_class = controller.try(:resource_owner_class)

      instance.authenticate resource_owner_class
      instance.response
    end

    def initialize request, controller
      self.request = request
      self.controller = controller
    end

    def authenticate resource_owner_class=User
      self.response = Response.new false
      authentication_params = params.permit(authentication: authentication_permitted_params).fetch(:authentication, {}).merge(resource_owner_class: resource_owner_class)
      response.authentication = Authentication.new (controller.try(:authentication_options) || {}).merge(authentication_params)
      response.apply
    end

    def authentication_permitted_params
      %i(auth_type client_id client_secret username password provider provider_token provider_token_secret)
    end
  end
end
