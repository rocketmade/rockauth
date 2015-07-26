module Rockauth
  class ProviderAuthenticationSerializer < BaseSerializer
    attributes :id, :provider, :provider_user_id
  end
end
