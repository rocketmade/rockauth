module Rockauth
  class AuthenticationSerializer < BaseSerializer
    attributes :id, :token, :expiration
    has_one :user, serializer: MeSerializer
    has_one :provider_authentication
  end
end
