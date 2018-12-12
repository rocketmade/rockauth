module Rockauth
  module Controllers
    autoload :Authentication, 'rockauth/controllers/authentication'
    autoload :Scope, 'rockauth/controllers/scope'
    autoload :UnsafeParameters, 'rockauth/controllers/unsafe_parameters'
  end
end
