module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes(*%i(id token token_id expiration client_version device_identifier device_os device_os_version device_description))

    has_one Rockauth::Configuration.resource_owner_class.model_name.element.to_sym
    has_one :provider_authentication

    def include_token_id
      object.token.present?
    end

    def include_jwt?
      object.token.present?
    end

    define_method Rockauth::Configuration.resource_owner_class.model_name.element do
      object.resource_owner
    end

    define_method(:"include_#{Rockauth::Configuration.resource_owner_class.model_name.element}?") do
      !scope.try(:include_authentication?)
    end
  end
end
