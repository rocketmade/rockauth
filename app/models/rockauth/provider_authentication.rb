require 'active_record'

module Rockauth
  class ProviderAuthentication < ActiveRecord::Base
    include Models::ProviderValidation
    include Models::ProviderAuthentication
    provider_authentication
  end
end
