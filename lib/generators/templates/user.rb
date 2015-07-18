class User < Rockauth::User
  resource_owner provider_authentication_class_name: '::ProviderAuthentication', authentication_class_name: '::Authentication'
end
