require 'jwt'

module Rockauth
  class Authentication < ActiveRecord::Base
    self.table_name = 'authentications'
    belongs_to :user, class_name: "Rockauth::User", inverse_of: :authentications
    belongs_to :provider_authentication, class_name: "Rockauth::ProviderAuthentication"

    scope :expired, -> { where('expiration <= ?', Time.now.to_i) }
    scope :unexpired, -> { where('expiration > ?', Time.now.to_i) }
    scope :for_token, -> (token) { where(encrypted_token: encrypt_token(token)) }

    attr_accessor :password
    attr_accessor :username
    attr_accessor :provider
    attr_accessor :provider_token
    attr_accessor :provider_secret_token
    attr_accessor :time_to_live
    attr_accessor :token
    attr_accessor :client_secret

    validates_presence_of :user
    validates_presence_of :expiration
    validates_presence_of :auth_type
    validates_inclusion_of :auth_type, in: %w(password assertion registration)
    validates_presence_of :client_id
    validates_presence_of :client_secret, on: :create

    alias_method :resource_owner, :user

    before_validation on: :create do
      self.expiration ||= Time.now.to_i + time_to_live
      if password?
        self.user = User.with_username(username).first
      elsif assertion?
        self.provider_authentication = ProviderAuthentication.new provider: provider, provider_token: provider_token, provider_secret_token: provider_secret_token
        provider_authentication.verify_with_provider
        self.user = provider_authentication.user
      end

      true
    end

    validates_presence_of :username, if: :password?, on: :create
    validates_presence_of :password, if: :password?, on: :create
    validate on: :create, if: :password? do
      if user.present? && !user.authenticate(password)
        errors.add :password, :invalid
      end
    end

    validates_presence_of :provider_authentication, if: :assertion?, on: :create
    validate on: :create, if: :assertion? do
      errors.add :provider_token, :invalid unless provider_authentication.valid?
    end

    validate on: :create do
      if client_id.present?
        client = Configuration.clients.find { |c| c.id == client_id }
        if client.blank?
          errors.add :client_id, :invalid
        elsif client.secret != client_secret
          errors.add :client_secret, :invalid
        end
      end
    end

    after_initialize do
      self.salt ||= SecureRandom.base64(12)
      true
    end

    before_create do
      generate_token
      encrypt_token
      true
    end

    def password?
      auth_type == 'password'
    end

    def assertion?
      auth_type == 'assertion'
    end

    def registration?
      auth_type == 'registration'
    end

    def time_to_live
      @time_to_live ||= Configuration.token_time_to_live
    end

    def generate_token
      self.token ||= JWT.encode token_payload, salt, 'HS256'
    end

    def encrypt_token
      self.encrypted_token ||= self.class.encrypt_token token
    end

    def self.encrypt_token tok
      Digest::SHA2.hexdigest tok
    end

    def active?
      Time.at(expiration) > Time.now
    end

    def token_payload
      { exp: expiration, user_id: user_id }
    end
  end
end
