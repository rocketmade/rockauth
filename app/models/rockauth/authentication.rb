module Rockauth
  class Authentication < ActiveRecord::Base
    include Models::Authentication
    rockauth_authentication
  end
end
