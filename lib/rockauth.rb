require 'rails'
require 'active_support'
module Rockauth
  extend ActiveSupport::Autoload
  autoload :Authenticator
  autoload :Client
  autoload :Configuration
  autoload :Controllers
  autoload :Engine
  autoload :Errors
  autoload :Models
  autoload :ProviderUserInformation
  autoload :Routes
end
require 'rockauth/configuration'
require 'rockauth/engine'
