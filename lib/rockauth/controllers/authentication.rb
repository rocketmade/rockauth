module Rockauth
  module Controllers::Authentication
    extend ActiveSupport::Concern

    def render_error status_code=500, message=I18n.t("rockauth.errors.server_error"), validation_errors=nil
      render json: Errors::ControllerError.new(status_code, message, validation_errors), serializer: ErrorSerializer, status: status_code
    end

    def render_unauthorized
      render_error 401, I18n.t("rockauth.errors.unauthorized")
    end

    def authenticate_resource_owner!
      render_unauthorized unless current_authentication.try(:active?)
    end

    def current_resource_owner
      @current_resource_owner ||= current_authentication.try(:resource_owner)
    end

    def current_authentication
      if @_authentication_checked
        @current_authentication
      else
        @_authentication_checked = true
        @current_authentication = Authenticator.verified_authentication_for_request request, self
      end
    end

    included do
      helper_method :current_resource_owner
      helper_method :current_authentication
    end
  end
end
