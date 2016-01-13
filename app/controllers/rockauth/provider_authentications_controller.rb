require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class ProviderAuthenticationsController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization
    include Rockauth::Controllers::Scope

    before_filter :authenticate_resource_owner!
    serialization_scope :view_context

    def index
      render json: collection
    end

    def create
      build_resource
      render_resource_or_error resource.save
    end

    def show
      render_resource
    end

    def update
      resource.assign_attributes permitted_params[:provider_authentication]
      render_resource_or_error resource.save
    end

    def destroy
      if resource.destroy
        render nothing: true, status: 200
      else
        render_action_error 409
      end
    end

    def render_resource
      render json: resource, status: 200
    end

    def render_action_error error_status=400
      render_error error_status, I18n.t("rockauth.errors.#{action_name}_error", resource: resource.class.model_name.human), resource.errors
    end

    def render_resource_or_error successful, error_status: 400
      if successful
        render_resource
      else
        render_action_error error_status
      end
    end

    protected

    def resource
      @provider_authentication ||= current_resource_owner.provider_authentications.find(params[:id])
    end

    def collection
      @provider_authentications ||= current_resource_owner.provider_authentications
    end

    def permitted_params
      params.permit(provider_authentication: %i{provider provider_access_token})
    end

    def build_resource
      @provider_authentication ||= current_resource_owner.provider_authentications.build permitted_params[:provider_authentication]
    end
  end
end
