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

    def email_required?
      false
    end

    def password_required?
      false
    end
  end
end
