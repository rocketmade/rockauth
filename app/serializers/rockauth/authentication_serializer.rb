module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes(*%i(id jwt token_id expiration client_version device_identifier device_os device_os_version device_description))

    has_one :resource_owner, serializer: MeSerializer
    has_one :provider_authentication

    def include_token_id
      object.jwt.present?
    end

    def include_jwt?
      object.jwt.present?
    end

    def include_resource_owner?
      !scope.try(:include_authentication?)
    end
  end
end
