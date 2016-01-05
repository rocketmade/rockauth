module Rockauth
  module Models
    autoload :Authentication,         'rockauth/models/authentication'
    autoload :ProviderAuthentication, 'rockauth/models/provider_authentication'
    autoload :ProviderValidation,     'rockauth/models/provider_validation'
    autoload :ResourceOwner,          'rockauth/models/resource_owner'
    autoload :User,                   'rockauth/models/user'
  end
end
