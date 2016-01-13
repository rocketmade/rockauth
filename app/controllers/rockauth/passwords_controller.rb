require 'rails-api'
require 'active_model_serializers'

module Rockauth
  class PasswordsController < ActionController::API
    include Rockauth::Controllers::Scope

    before_filter do
      raise ActiveRecord::NotFoundError unless scope_settings[:password_reset]
    end

    rescue_from ActionController::ParameterMissing do |exception|
      errors = ActiveModel::Errors.new nil
      errors.add(exception.param, I18n.t('errors.messages.invalid'))
      render_error 400, I18n.t('rockauth.errors.forgot_password_failed'), errors
    end

    def forgot
      username = params.require(:user).require(:username)
      @resource_owner = resource_owner_class.with_username(username).first
      if @resource_owner.present? && @resource_owner.has_email?
        @resource_owner.initiate_password_reset
        render_forgot_success
      else
        if Rockauth::Configuration.forgot_password_always_successful
          render_forgot_success
        else
          render_forgot_password_not_found
        end
      end
    end

    def reset
      token = params.require(:user).require(:password_reset_token)
      @resource_owner = resource_owner_class.with_valid_password_reset_token(token).first
      if @resource_owner.present?
        @resource_owner.set_password_for_reset params.require(:user).require(:password)
        if @resource_owner.save
          render json: { meta: { message: I18n.t("rockauth.forgot_password_success") } }, status: 200
        else
          Rails.logger.error "Could not reset a users password despite a valid token: #{@resource_owner.errors.to_json}"
          render_error 400, I18n.t("rockauth.errors.forgot_password_failed"), @resource_owner.errors
        end
      else
        errors = resource_owner_class.new.errors
        errors.add(:password_reset_token, :invalid)
        render_error 400, I18n.t("rockauth.errors.forgot_password_invalid_token"), errors
      end
    end

    protected

    def render_forgot_success
      render json: { meta: { message: I18n.t('rockauth.forgot_password_email_sent') } }, status: 200
    end

    def render_forgot_password_not_found
      errors = ActiveModel::Errors.new nil
      errors.add(:username, I18n.t('errors.messages.invalid'))
      render_error 400, I18n.t('rockauth.errors.forgot_password_not_found'), errors
    end
  end
end
