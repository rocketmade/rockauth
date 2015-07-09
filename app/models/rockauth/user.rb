require 'active_record'

module Rockauth
  class User < ActiveRecord::Base
    self.table_name = 'users'
    has_many :provider_authentications, class_name: 'Rockauth::ProviderAuthentication', dependent: :destroy
    has_many :authentications, class_name: 'Rockauth::Authentication', dependent: :destroy

    validates_presence_of :email, if: :email_required?
    validates_format_of :email, with: Config.email_regexp, if: -> { (new_record? || email_changed?) }, allow_blank: true

    has_secure_password validations: true
    validates_presence_of :password, if: :password_required?
    validates_length_of :password, in: Config.allowed_password_length

    def email_required?
      false
    end

    def password_required?
      false # new_record?
    end
  end
end
