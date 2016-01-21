module Rockauth
  module Controllers::Authentication
    extend ActiveSupport::Concern

    def render_error status_code=500, message=I18n.t("rockauth.errors.server_error"), validation_errors=nil
      error = Errors::ControllerError.new(status_code, message, validation_errors)
      render Rockauth::Configuration.error_renderer.call(error)
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
      if @current_authentication.present? || @_authentication_checked
        @current_authentication
      else
        @_authentication_checked = true
        @current_authentication = Authenticator.verified_authentication_for_request request, self
      end
    end
    included do
      include ActionController::Helpers # TODO: we dont want to force apis to have helpers if we can avoid it.....
      helper_method :current_resource_owner
      helper_method :current_authentication
    end
  end
end
