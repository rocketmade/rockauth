require 'warden'

begin
  require 'useragent'
rescue LoadError
end

module Rockauth
  module Warden
    class Railtie < ::Rails::Railtie
      config.app_middleware.use ::Warden::Manager do |manager|
        manager.default_strategies :rockauth_password, :rockauth_token
        manager.failure_app = Rockauth::SessionsController.action(:failure)
      end
    end

    def self.scopes
      @scopes ||= {}
    end

    def self.model_for_scope scope=:default
      scopes[scope.to_sym] || scope.to_s.camelize.safe_constantize
    end

    class PasswordStrategy < ::Warden::Strategies::Base
      def valid?
        params.fetch(param_key, {}).has_key?("username") && params.fetch(param_key, {}).has_key?("password")
      end

      def param_key
        :authentication
      end

      def params
        @params ||= ActionController::Parameters.new(super)
      end

      def resource_owner_class
        Rockauth::Warden.model_for_scope(scope)
      end

      def inject_params
        params[param_key] ||= {}
        params[param_key].merge!(inferred_params)
      end

      def inferred_params
        result = {
          client_id: Rockauth::Configuration.session_client.id,
          client_secret: Rockauth::Configuration.session_client.secret,
          auth_type: 'password'
        }

        if defined?(UserAgent) && request.user_agent.present?
          agent = UserAgent.parse(request.user_agent)

          result.merge!(device_os: agent.browser,
                        device_os_version: Array(agent.version).join('.'),
                        device_description: [agent.browser, Array(agent.version).join('.'), agent.platform, agent.os].compact.join(' ') )
        end

        result
      end

      def authenticate!
        inject_params
        auth = Authenticator.authentication_request(request, self)
        if auth.success?
          success!(auth.authentication)
        else
          fail auth.error.message
        end
      end
    end

    class TokenStrategy < ::Warden::Strategies::Base
      def valid?
        params.has_key? 'token'
      end

      def authenticate!
        auth = Rockauth::Configuration.authentication_class.for_token(params['token'])
        auth.token = params['token']
        if auth.present?
          success!(auth)
        else
          fail auth.error.message
        end
      end
    end
  end
end

Warden::Strategies.add(:rockauth_password, Rockauth::Warden::PasswordStrategy)
Warden::Strategies.add(:rockauth_token, Rockauth::Warden::TokenStrategy)

Warden::Manager.serialize_into_session do |authentication|
  authentication.token
end

Warden::Manager.serialize_from_session do |token|
  Rockauth::Configuration.authentication_class.for_token(token)
end
