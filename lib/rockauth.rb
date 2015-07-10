require 'rails'
require 'active_support'
module Rockauth
  ROOT = File.dirname(__FILE__)
  autoload :Authenticator, 'rockauth/authenticator'
  autoload :Client, 'rockauth/client'
  autoload :Config, 'rockauth/config'
  autoload :ControllerConcern, 'rockauth/controller_concern'
  autoload :Engine, 'rockauth/engine'
  autoload :Errors, 'rockauth/errors'
  #autoload :User, File.join(ROOT, '../app/models/rockauth/user')
  #autoload :Authorization, File.join(ROOT, '../app/models/rockauth/authorization')
  #autoload :AuthenticationsController, File.join(ROOT, '../app/controllers/rockauth/authentications_controller')
end

# require 'rockauth/config'
require 'rockauth/engine'
# require 'rockauth/authenticator'
require File.expand_path('../../app/models/rockauth/user', __FILE__)
require File.expand_path('../../app/models/rockauth/provider_authentication', __FILE__)
require File.expand_path('../../app/models/rockauth/authentication', __FILE__)
require File.expand_path('../../app/controllers/rockauth/authentications_controller', __FILE__)
