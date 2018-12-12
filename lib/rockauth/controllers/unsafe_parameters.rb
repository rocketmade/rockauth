module Rockauth
  module Controllers::UnsafeParameters
    class UnsafeParametersError < ActionController::BadRequest; end

    extend ActiveSupport::Concern

    included do
      before_filter :reject_unsafe_parameters!

      rescue_from UnsafeParametersError do
        render_error 400, I18n.t("rockauth.errors.unsafe_parameters_error")
      end

    end

    def detect_unsafe_parameters hash=request.GET
      if hash.is_a? Hash
        return hash.any? do |key, value|
          return true if Rockauth::Configuration.unsafe_url_parameters.map(&:to_s).include? key.to_s
          return true if detect_unsafe_parameters value
        end
      elsif hash.is_a? Array
        return hash.any? do |item|
          detect_unsafe_parameters item
        end
      else
        return false
      end
    end


    def reject_unsafe_parameters!
      return true if Rockauth::Configuration.unsafe_url_parameters.empty?

      if detect_unsafe_parameters
        fail UnsafeParametersError, I18n.t("rockauth.errors.unsafe_parameters_error")
      end

      true
    end
  end
end
