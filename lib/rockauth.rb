require 'rails'
require 'active_support'
module Rockauth
  ROOT = File.dirname(__FILE__)
  autoload :Config, 'rockauth/config'
  autoload :Engine, 'rockauth/engine'
  autoload :Authenticator, 'rockauth/authenticator'
  #autoload :User, File.join(ROOT, '../app/models/rockauth/user')
  #autoload :Authorization, File.join(ROOT, '../app/models/rockauth/authorization')
  #autoload :AuthenticationsController, File.join(ROOT, '../app/controllers/rockauth/authentications_controller')
end

#require 'rockauth/config'
require 'rockauth/engine'
#require 'rockauth/authenticator'
require File.expand_path 'app/models/rockauth/user'
require File.expand_path 'app/models/rockauth/provider_authentication'
require File.expand_path 'app/models/rockauth/authentication'
require File.expand_path 'app/controllers/rockauth/authentications_controller'
