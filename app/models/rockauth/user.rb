module Rockauth
  class User < ActiveRecord::Base
    self.table_name = 'users'

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, Rockauth)
    end

    def model_name
      self.class.model_name
    end
    include Models::ResourceOwner

    resource_owner

    include Models::User
  end
end
