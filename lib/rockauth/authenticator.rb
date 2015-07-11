module Rockauth
  class Authenticator
    class AuthenticationResponse < Struct.new(:success, :resource_owner, :authentication)
      alias_method :success?, :success

      def initialize *args
        super
      end

      def apply
        self.success = authentication.save
        self.resource_owner = authentication.resource_owner # owner is set before_validation
      end

      def error
        if authentication.present? && !authentication.errors.empty?
          @error ||= Errors::ControllerError.new 400, I18n.t("rockauth.errors.authentication_failed"), authentication.errors.as_json
        end
      end
    end

    attr_accessor :request
    attr_accessor :controller
    attr_accessor :response

    delegate :params, to: :controller

    def self.authentication_from_request request, controller
      bearer, token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ')
      if bearer == "bearer" && token.present?
        Authentication.for_token(token).first
      else
        nil
      end
    end

    def self.from_request request, controller
      instance = new request, controller

      instance.authenticate
      instance.response
    end

    def initialize request, controller
      self.request = request
      self.controller = controller
    end

    def authenticate
      self.response = AuthenticationResponse.new false
      authentication_params = params.permit(authentication: authentication_permitted_params).fetch(:authentication, {})
      response.authentication = Authentication.new (controller.try(:authentication_options) || {}).merge(authentication_params)
      response.apply
    end

    def authentication_permitted_params
      %i(auth_type client_id client_secret username password assertion provider provider_token provider_token_secret)
    end
  end
end
