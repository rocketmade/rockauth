module Rockauth
  class Authenticator
    class AuthenticationResponse < Struct.new(:success, :errors, :resource_owner, :authentication)
      alias_method :success?, :success

      def initialize *args
        super
        self.errors ||= []
      end

      def error_messages
        errors.map(&:message)
      end

      def apply
        self.success = authentication.save
        self.resource_owner = authentication.resource_owner # owner is set before_validation
      end
    end

    class AuthenticationError < StandardError
      @status_code = 400 # Bad Request, its YOUR fault

      def self.status_code= code
        @status_code = code
      end

      def self.status_code
        @status_code
      end

      delegate :status_code, to: :class
    end

    class InvalidTokenError < StandardError; end
    class ExpiredTokenError < AuthenticationError; end

    class InvalidParameterError < AuthenticationError
      attr_accessor :parameter
      def initialize param
        self.parameter = param
        super I18n.t('rockauth.errors.invalid_parameter_error', parameter: param)
      end
    end

    class MissingParameterError < AuthenticationError
      attr_accessor :parameter
      def initialize param
        self.parameter = param
        super I18n.t('rockauth.errors.missing_parameter_error', parameter: param)
      end
    end

    class MissingParameterError < AuthenticationError
      attr_accessor :parameter
      def initialize param
        self.parameter = param
        super I18n.t('rockauth.errors.missing_parameter_error', parameter: param)
      end
    end

    attr_accessor :request
    attr_accessor :controller
    attr_accessor :response

    delegate :params, to: :controller

    def self.validate_token token

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

      validate_parameters

      if response.errors.empty?
        authentication_params = params.require(:authentication).permit(authentication_permitted_params)
        response.authentication = Authentication.new (controller.try(:authentication_options) || {}).merge(authentication_params)
        response.apply
      else
        false
      end
    end

    def authentication_permitted_params
      %i(auth_type client_id client_secret username password assertion provider provider_token provider_token_secret)
    end

    def validate_parameters
      if controller.params[:authentication].blank?
        response.errors << MissingParameterError.new(:authentication).tap do |error|
          error.set_backtrace caller
        end
      end

      authentication_params = params.fetch(:authentication, {})

      missing_params = (%i(auth_type client_id client_secret) + required_params_for_type(authentication_params[:auth_type])).each do |param|
        if authentication_params[param].blank?
          response.errors << MissingParameterError.new(param).tap do |error|
            error.set_backtrace caller
          end
        end
      end

      if authentication_params[:auth_type].present? && !valid_auth_types.include?(authentication_params[:auth_type])
        response.errors << InvalidParameterError.new(:auth_type).tap do |error|
          error.set_backtrace caller
        end
      end
    end

    def valid_auth_types
      %w(password assertion)
    end

    def required_params_for_type type
      case type
      when 'password'
        %i(username password)
      when 'assertion'
        %i(provider provider_token)
      else
        []
      end
    end
  end
end
