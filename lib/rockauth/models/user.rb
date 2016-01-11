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

      def self.with_valid_password_reset_token token
        where(password_reset_token: token).where('password_reset_token_expires_at > ?', DateTime.now)
      end

      define_method :email_required? do
        new_record? && provider_authentications.empty?
      end

      define_method :password_required? do
        new_record? && provider_authentications.empty?
      end

      define_method :has_email? do
        email.present?
      end

      define_method :initiate_password_reset do
        self.password_reset_token = SecureRandom.urlsafe_base64
        self.password_reset_token_expires_at = Rockauth::Configuration.password_reset_token_time_to_live.from_now
        if self.save
          Rails.logger.info "Sending password reset token for #{self.class}##{self.id}"
          Rockauth::PasswordMailer.reset(email, password_reset_token).deliver_later
        else
          Rails.logger.error "Could not send password reset for #{self.class}##{self.id}: #{self.errors.to_json}"
        end
      end

      define_method :set_password_for_reset do |new_password|
        self.password = new_password
        self.password_reset_token = nil
        self.password_reset_token_expires_at = nil
      end
    end
  end
end
