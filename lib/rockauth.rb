require 'rails'
require 'active_support'
module Rockauth
  autoload :Authenticator,             'rockauth/authenticator'
  autoload :Client,                    'rockauth/client'
  autoload :Configuration,             'rockauth/configuration'
  autoload :Controllers,               'rockauth/controllers'
  autoload :Engine,                    'rockauth/engine'
  autoload :Errors,                    'rockauth/errors'
  autoload :ProviderUserInformation,   'rockauth/provider_user_information'
  autoload :Models,                    'rockauth/models'
end
require 'rockauth/configuration'
require 'rockauth/engine'
