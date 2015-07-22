require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class MeController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization

    before_filter :authenticate_resource_owner!, except: [:create]

    helper_method :include_authentication?

    serialization_scope :view_context

    def create
      build_resource
      render_resource_or_error resource.save
    end

    def show
      render_resource
    end

    def update
      resource.assign_attributes permitted_params.fetch(:user, {})
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
      render json: resource, serializer: MeSerializer, status: 200
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
      @user ||= current_resource_owner
    end

    def permitted_params
      permitted = params.permit(user: [*%i(email password),
                                       provider_authentications: [:provider, :provider_access_token, :provider_access_token_secret],
                                       authentication: [*%i(auth_type client_id client_secret client_version device_identifier device_description device_os device_os_version)]])
      user_params = permitted.fetch(:user, {})

      if action_name == 'update'
        user_params.delete :authentication
      elsif user_params.has_key? :authentication
        user_params[:authentications_attributes] = [user_params.delete(:authentication).merge(auth_type: 'registration')]
      end

      if user_params.has_key? :provider_authentications
        user_params[:provider_authentications_attributes] = user_params.delete(:provider_authentications)
      end

      permitted
    end

    def build_resource
      @user = User.new.tap do |user|
        user.assign_attributes permitted_params.fetch(:user, {})
      end
    end

    def include_authentication?
      action_name == 'create'
    end
  end
end
