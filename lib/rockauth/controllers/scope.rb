module Rockauth
  module Controllers::Scope
    extend ActiveSupport::Concern

    def resource_owner_class_name
      params[:resource_owner_class_name].to_s
    end

    def resource_owner_class
      @resource_owner_class ||= resource_owner_class_name.safe_constantize
    end

    def scope_settings
      Rockauth::Configuration.controller_mappings[resource_owner_class_name]
    end
  end
end
