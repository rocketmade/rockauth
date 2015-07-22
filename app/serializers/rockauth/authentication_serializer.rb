module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes :id, :token, :expiration
    has_one :resource_owner, serializer: MeSerializer
    has_one :provider_authentication

    def include_resource_owner?
      !scope.try(:include_authentication?)
    end
  end
end
