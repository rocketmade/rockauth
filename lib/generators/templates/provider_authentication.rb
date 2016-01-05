class ProviderAuthentication < ActiveRecord::Base
  include Rockauth::Models::ProviderValidation
  include Rockauth::Models::ProviderAuthentication
  provider_authentication authentication_class_name: '::Authentication'
end
