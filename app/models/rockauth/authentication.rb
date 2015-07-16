require 'jwt'

module Rockauth
  class Authentication < ActiveRecord::Base
    self.table_name = 'authentications'
    belongs_to :resource_owner, polymorphic: true, inverse_of: :authentications
    belongs_to :provider_authentication, class_name: "Rockauth::ProviderAuthentication"

    accepts_nested_attributes_for :provider_authentication

    scope :expired, -> { where('expiration <= ?', Time.now.to_i) }
    scope :unexpired, -> { where('expiration > ?', Time.now.to_i) }
    scope :for_token, -> (token) { where(hashed_token_id: hash_token_id(token)) }

    %i(resource_owner_class password username time_to_live token_id jwt client_secret).each do |key|
      attr_accessor key
    end

    validates_presence_of  :auth_type
    validates_inclusion_of :auth_type, in: %w(password assertion registration)
    validates_presence_of  :client_id
    validates_presence_of  :client_secret, on: :create
    validates_presence_of  :resource_owner
    validates_presence_of  :expiration
    validates_presence_of  :issued_at
    validates_presence_of  :auth_type
    validates_inclusion_of :auth_type,     in: %w(password assertion registration)
    validates_presence_of  :client_id
    validates_presence_of  :client_secret, on: :create

    before_validation on: :create do
      self.expiration ||= Time.now.to_i + time_to_live
      self.issued_at ||= Time.now.to_i

      if password?
        self.resource_owner = resource_owner_class.with_username(username).first
      elsif assertion?
        build_provider_authentication unless self.provider_authentication.present?
        provider_authentication.authentication = self
        self.provider_authentication = provider_authentication.exchange
        self.resource_owner = provider_authentication.resource_owner
      end

      true
    end

    validates_presence_of :username, if: :password?, on: :create
    validates_presence_of :password, if: :password?, on: :create
    validate on: :create, if: :password? do
      if resource_owner.present? && !resource_owner.authenticate(password)
        errors.add :password, :invalid
      end
    end

    validates_presence_of :provider_authentication, if: :assertion?, on: :create

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

    before_create do
      generate_token_id
      generate_jwt
      hash_token_id
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

    def generate_token_id
      self.token_id ||= SecureRandom.base64(24)
    end

    def hash_token_id
      self.hashed_token_id ||= self.class.hash_token_id token_id
    end

    # TODO: Remove salt and BCrypt this?
    def self.hash_token_id jti
      Digest::SHA2.hexdigest jti
    end

    def active?
      Time.at(expiration) > Time.now
    end

    def verify! payload
      self if active? &&
              payload['iat'] == issued_at &&
              payload['exp'] == expiration
    end

    def generate_jwt
      self.jwt ||= JWT.encode jwt_payload, Configuration.jwt.secret, Configuration.jwt.signing_method
    end

    def jwt_payload
      {
        iat: issued_at,
        exp: expiration,
        aud: client_id,
        sub: resource_owner_id,
        jti: token_id
      }
    end
  end
end
