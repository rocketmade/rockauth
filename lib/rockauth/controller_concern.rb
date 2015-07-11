module Rockauth
  module ControllerConcern
    extend ActiveSupport::Concern

    def render_error status_code=500, message=I18n.t("rockauth.errors.server_error"), validation_errors=nil
      render json: Errors::ControllerError.new(status_code, message, validation_errors), serializer: ErrorSerializer, status: status_code
    end

    def render_unauthorized
      render_error 403, I18n.t("rockauth.errors.unauthorized")
    end

    def authenticate_resource_owner!
      render_unauthorized unless current_authentication.try(:active?)
    end

    def current_user
      @current_user ||= current_authentication.try(:user)
    end

    def current_authentication
      @current_authentication ||= Authenticator.authentication_from_request request, self
    end
  end
end
