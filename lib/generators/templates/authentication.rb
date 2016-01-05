class Authentication < ActiveRecord::Base
  include Rockauth::Models::Authentication
  rockauth_authentication provider_authentication_class_name: "::ProviderAuthentication"
end
