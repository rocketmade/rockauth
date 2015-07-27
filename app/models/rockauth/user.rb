require 'active_record'

module Rockauth
  class User < ActiveRecord::Base
    self.table_name = 'users'
    include Models::ResourceOwner

    resource_owner

    validates_presence_of :email, if: :email_required?
    validates_format_of   :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/, if: -> { (new_record? || email_changed?) }, allow_blank: true

    has_secure_password   validations: false
    validates_presence_of :password, if: :password_required?
    validates_length_of   :password, in: Configuration.allowed_password_length, allow_nil: true, allow_blank: true

    scope :with_username, -> (username) { where("#{self.table_name}.email ILIKE ?", username) }

    def self.active_model_serializer
      Rockauth::Configuration.serializers.user.safe_constantize
    end

    def email_required?
      new_record? && provider_authentications.empty?
    end

    def password_required?
      new_record? && provider_authentications.empty?
    end
  end
end
