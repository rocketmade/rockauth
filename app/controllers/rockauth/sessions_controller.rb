
module Rockauth
  class SessionsController < ActionController::Base
    include Rockauth::Controllers::Scope

    before_filter :set_variables
    helper_method :resource
    helper_method :param_key
    helper_method :resource_owner_class
    layout :configured_layout

    def new
      build_resource

      if warden.user(@scope).present?
        redirect_to (consume_sign_in_uri || scope_settings[:after_sign_in_url]), flash: { notice: I18n.t("rockauth.sessions.existing_session") }
      end
    end

    def create
      warden.authenticate scope: @scope
      if warden.user(@scope).present?
        redirect_to consume_sign_in_uri || scope_settings[:after_sign_in_url], flash: { notice: I18n.t("rockauth.sessions.created") }
      else
        build_resource
        render :new, flash: { error: I18n.t("rockauth.sessions.creation_failed") }
      end
    end

    def destroy
      env['warden'].user(@scope).try(:destroy)
      env['warden'].logout(@scope)
      redirect_to scope_settings[:after_sign_out_url], flash: { notice: I18n.t("rockauth.sessions.destroyed") }
    end

    def failure
      if params[:controller].split('/').last == 'sessions' && %w{new create}.include?(params['action'])
        build_resource
        render :new, flash: { error: I18n.t("rockauth.sessions.required") }
      else
        redirect_to [:new, @scope, :session]
      end
    end

    def resource_owner_class
      @resource_owner_class ||= (params[:resource_owner_class_name] || env['warden.options'][:scope].to_s.camelize).safe_constantize
    end

    protected

    def configured_layout
      (Rockauth::Configuration.session_layout || -> (*_) { 'application' }).call(@scope)
    end

    def warden
      env['warden']
    end

    def set_variables
      @authentication_class = Rockauth::Configuration.authentication_class
      @scope = resource_owner_class.model_name.param_key
    end

    def resource
      @authentication
    end

    def build_resource
      @authentication = @authentication_class.new permitted_params[param_key]
    end

    def permitted_params
      params.permit(param_key => [:username, :password, :token])
    end

    def param_key
      :authentication
    end

    def consume_sign_in_uri
      value = session[:"#{@scope}_sign_in_return_uri"]
      session[:"#{@scope}_sign_in_return_uri"] = nil
      value
    end
  end
end
