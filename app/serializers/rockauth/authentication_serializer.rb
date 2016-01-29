module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes(*%i(id token token_id expiration client_version device_identifier device_os device_os_version device_description resource_owner_type))

    def root
      'authentication'
    end

    has_one :resource_owner
    has_one :provider_authentication

    def include_token_id
      object.token.present?
    end

    def include_jwt?
      object.token.present?
    end

    def resource_owner_type
      object.resource_owner_type.to_s.underscore
    end

    def include_resource_owner?
      !scope.try(:include_authentication?)
    end
  end
end
