require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class AuthenticationsController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization
    include Rockauth::Controllers::Scope

    serialization_scope :view_context

    before_filter :authenticate_resource_owner!, except: [:authenticate]

    after_action  :after_authentication, only: [:authenticate]
    before_action :before_logout,        only: [:destroy]

    def index
      @authentications = current_resource_owner.authentications
      render json: @authentications, include: Rockauth::Configuration.filter_include(self, true)
    end

    def authenticate
      @auth_response = Authenticator.authentication_request(request, self)
      if @auth_response.success
        @current_authentication = @auth_response.authentication
      end
      render @auth_response.render.reverse_merge(include: Rockauth::Configuration.filter_include(self, false))
    end

    def destroy
      @authentication = current_authentication
      @authentication = current_resource_owner.authentications.find(params[:id]) if params[:id].present?
      if resource.public_send(Rockauth::Configuration.signout_method)
        render json: {}, status: 200
      else
        render_error 409, I18n.t("rockauth.errors.destroy_error", resource: "Authentication")
      end
    end

    def show
      @authentication = current_resource_owner.authentications.find(params[:id])
      render json: @authentication, include: Rockauth::Configuration.filter_include(self, false)
    end

    def resource
      @authentication
    end

    private

    def after_authentication
      current_resource_owner.run_hook(:after_authentication, current_authentication) if current_authentication
    end

    def before_logout
      current_resource_owner.run_hook(:before_logout, current_authentication) if current_authentication
    end
  end
end
