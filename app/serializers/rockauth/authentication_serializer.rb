module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes(*%i(id token expiration client_version device_identifier device_os device_os_version device_description))

    has_one :resource_owner, serializer: MeSerializer
    has_one :provider_authentication

    def include_token?
      object.token.present?
    end

    def include_resource_owner?
      !scope.try(:include_authentication?)
    end
  end
end
