require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class MeController < ActionController::API
    include ActionController::Helpers
    include ActionController::Serialization
    include Rockauth::Controllers::Scope

    before_filter :authenticate_resource_owner!, except: [:create]

    before_filter only: :create do
      raise ActiveRecord::NotFoundError unless scope_settings[:registration]
    end

    helper_method :include_authentication?

    serialization_scope :view_context

    def create
      build_resource

      # Makes the UserSerializer work properly and display all probative data.
      @current_resource_owner = resource
      @current_authentication = resource.try(:authentication)

      render_resource_or_error resource.save
    end

    def show
      render_resource
    end

    def update
      resource.assign_attributes permitted_params.fetch(param_key, {})
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
      render json: resource, status: 200, include: Rockauth::Configuration.filter_include(self, false)
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
      @resource_owner ||= current_resource_owner
    end

    def param_key
      resource_owner_class.model_name.param_key.to_sym
    end

    def permitted_params
      permitted = params.permit(param_key => [*%i(email password first_name last_name),
                                       :provider_authentications => [:provider, :provider_access_token, :provider_access_token_secret],
                                       :authentication => [*%i(auth_type client_id client_secret client_version device_identifier device_description device_os device_os_version)]]).to_h.with_indifferent_access
      resource_params = permitted[param_key] || {}

      if action_name == 'update'
        resource_params.delete :authentication
      else
        resource_params[:authentications_attributes] = [(resource_params.delete(:authentication) || {}).merge(auth_type: 'registration')]
      end

      if resource_params.has_key? :provider_authentications
        resource_params[:provider_authentications_attributes] = resource_params.delete(:provider_authentications)
      end

      permitted
    end

    def build_resource
      @resource_owner = resource_owner_class.new.tap do |owner|
        owner.assign_attributes permitted_params[param_key]
      end
    end

    def include_authentication?
      action_name == 'create'
    end
  end
end
