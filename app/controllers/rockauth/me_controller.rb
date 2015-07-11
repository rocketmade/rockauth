require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class MeController < ActionController::API
    include ActionController::Serialization
    before_filter :authenticate_resource_owner!, except: [:create]

    helper_method :include_registration?

    serialization_scope :view_context

    def create
      build_resource

      if resource.save
        render json: resource, serializer: MeSerializer
      else
        render json: Errors::ControllerError.new(400, "User could not be created", resource.errors), serializer: ErrorSerializer, status: 400
      end
    end

    def show
      render json: resource, serializer: MeSerializer
    end

    def update
      resource.assign_attributes permitted_params.fetch(:user, {})
      if resource.save
        render json: resource, serializer: MeSerializer
      else
        render json: Errors::ControllerError.new(400, "User could not be updated", resource.errors), serializer: ErrorSerializer, status: 400
      end
    end

    def destroy
      if resource.destroy
        render nothing: true, status: 200
      else
        render json: Errors::ControllerError.new(400, "User could not be deleted", resource.errors), serializer: ErrorSerializer, status: 400
      end
    end

    protected

    def resource
      @user ||= current_user
    end

    def permitted_params
      permitted = params.permit(user: [*%i(email password), authentication: [*%i(auth_type client_id client_secret)], provider_authentications: []])
      user_params = permitted.fetch(:user, {})

      if action_name == "update"
        user_params.delete :authentication
      elsif user_params.has_key? :authentication
        user_params[:authentications_attributes] = [user_params.delete(:authentication).merge(auth_type: 'registration')]
      end

      permitted
    end

    def build_resource
      @user = User.new.tap do |user|
        user.assign_attributes permitted_params.fetch(:user, {})
      end
    end

    def include_registration?
      action_name == "create"
    end
  end
end
