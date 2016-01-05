module Rockauth
  class User < ActiveRecord::Base
    self.table_name = 'users'
    include Models::ResourceOwner

    resource_owner

    include Models::User
  end
end
