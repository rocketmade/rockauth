module Rockauth
  class Authenticator::Response < Struct.new(:success, :resource_owner, :authentication)
    alias_method :success?, :success

    def apply
      self.success = authentication.save
      self.resource_owner = authentication.resource_owner # owner is set before_validation
    end

    def status_code
      if @error.present?
        @error.status_code
      else
      end
    end

    def error
      if authentication.present? && !authentication.errors.empty?
        @error ||= Errors::ControllerError.new 400, I18n.t("rockauth.errors.authentication_failed"), authentication.errors.as_json
      end
    end

    def render
      if success?
        render_success
      else
        render_error
      end
    end

    def render_success
      { json: authentication, serializer: AuthenticationSerializer, status: 200 }
    end

    def render_error
      { json: error, serializer: ErrorSerializer, status: error.status_code }
    end
  end
end
