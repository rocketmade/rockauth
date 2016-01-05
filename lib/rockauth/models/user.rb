module Rockauth
  module Models::User
    extend ActiveSupport::Concern

    included do
      validates_presence_of   :email, if: :email_required?
      validates_uniqueness_of :email, case_sensitive: false, allow_nil: true
      validates_format_of     :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/, if: -> { (new_record? || email_changed?) }, allow_blank: true

      has_secure_password   validations: false
      validates_presence_of :password, if: :password_required?
      validates_length_of   :password, in: Configuration.allowed_password_length, allow_nil: true, allow_blank: true

      scope :with_username, -> (username) { where("#{self.table_name}.email ILIKE ?", username) }

      define_method :email_required? do
        new_record? && provider_authentications.empty?
      end

      define_method :password_required? do
        new_record? && provider_authentications.empty?
      end
    end
  end
end
