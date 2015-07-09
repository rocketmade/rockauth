require 'active_record'

module Rockauth
  class ProviderAuthentication < ActiveRecord::Base
    self.table_name = 'provider_authentications'
    belongs_to :user, class_name: "Rockauth::User"

    validates_presence_of :user
    validates_uniqueness_of :provider_user_id, scope: :provider
    validates_presence_of :provider
    validates_presence_of :provider_user_id
    validates_presence_of :provider_access_token
    validates_uniqueness_of :provider_user_id, scope: :provider
    validates_presence_of :provider_key

    def verify_with_provider
    end
  end
end
