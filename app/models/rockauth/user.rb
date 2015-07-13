require 'active_record'

module Rockauth
  class User < ActiveRecord::Base
    self.table_name = 'users'
    has_many :provider_authentications, inverse_of: :user, class_name: 'Rockauth::ProviderAuthentication', dependent: :destroy
    has_many :authentications, inverse_of: :user, class_name: 'Rockauth::Authentication', dependent: :destroy

    accepts_nested_attributes_for :authentications
    accepts_nested_attributes_for :provider_authentications

    validates_associated :authentications, on: :create

    validates_presence_of :authentications, on: :create

    validates_presence_of :email, if: :email_required?
    validates_format_of :email, with: Configuration.email_regexp, if: -> { (new_record? || email_changed?) }, allow_blank: true

    has_secure_password validations: true
    validates_presence_of :password, if: :password_required?
    validates_length_of :password, in: Configuration.allowed_password_length

    scope :with_username, -> (username) { where("#{self.table_name}.email ILIKE ?", username) }

    def email_required?
      false
    end

    def password_required?
      false # new_record?
    end
  end
end
