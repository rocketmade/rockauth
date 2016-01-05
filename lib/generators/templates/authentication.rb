class Authentication < ActiveRecord::Base
  include Rockauth::Models::Authentication
  rockauth_authentication
end
