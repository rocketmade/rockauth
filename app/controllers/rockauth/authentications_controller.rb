require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class AuthenticationsController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization

    serialization_scope :view_context

    before_filter :authenticate_resource_owner!, except: [:authenticate]

    def index
      @authentications = Authentication.where(resource_owner: current_resource_owner)
      render json: @authentications
    end

    def authenticate
      @auth_response = Authenticator.from_request(request, self)
      render @auth_response.render
    end

    def destroy
      record = current_authentication
      record = Authentication.where(resource_owner: current_resource_owner).find(params[:id]) if params[:id].present?
      if record.destroy
        render nothing: true, status: 200
      else
        render_error 409, I18n.t("rockauth.errors.destroy_error", resource: "Authentication")
      end
    end

    def resource
      @authentication
    end

    def authentication_options
      {}
    end

    def resource_owner_class
      Rockauth::Configuration.resource_owner_class
    end
  end
end
