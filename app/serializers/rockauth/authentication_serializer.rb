module Rockauth
  class AuthenticationSerializer < ActiveModel::Serializer
    attributes :id, :token, :expiration
    has_one :user, serializer: MeSerializer
    has_one :provider_authentication
  end
end
