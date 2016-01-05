class User < ActiveRecord::Base
  include Rockauth::Models::ResourceOwner

  resource_owner provider_authentication_class_name: '::ProviderAuthentication', authentication_class_name: '::Authentication'

  include Rockauth::Models::User
end
