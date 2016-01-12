require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class AuthenticationsController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization
    include Rockauth::Controllers::Scope

    serialization_scope :view_context

    before_filter :authenticate_resource_owner!, except: [:authenticate]

    def index
      @authentications = current_resource_owner.authentications
      render json: @authentications
    end

    def authenticate
      @auth_response = Authenticator.authentication_request(request, self)
      if @auth_response.success
        @current_resource_owner = @auth_response.resource_owner
      end
      render @auth_response.render
    end

    def destroy
      record = current_authentication
      record = current_resource_owner.authentications.find(params[:id]) if params[:id].present?
      if record.destroy
        render nothing: true, status: 200
      else
        render_error 409, I18n.t("rockauth.errors.destroy_error", resource: "Authentication")
      end
    end

    def resource
      @authentication
    end
  end
end
