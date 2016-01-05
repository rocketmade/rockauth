require 'jwt'

module Rockauth
  module Models::Authentication
    extend ActiveSupport::Concern

    def client
      @client ||= if client_id.present?
                    Configuration.clients.find { |c| c.id == client_id }
                  end
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

    def time_to_live= t
      @time_to_live = t
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

    def active?
      Time.at(expiration) > Time.now
    end

    def valid_payload? payload
      active? && payload['iat'] == issued_at && payload['exp'] == expiration
    end

    def generate_token
      self.token ||= JWT.encode jwt_payload, Configuration.jwt.secret, Configuration.jwt.signing_method
    end

    def jwt_payload
      {
        iss: Configuration.jwt.issuer,
        iat: issued_at,
        exp: expiration,
        aud: client_id,
        sub: resource_owner_id,
        jti: token_id
      }
    end

    module ClassMethods
      def rockauth_authentication include_associations: true, provider_authentication_class_name: "Rockauth::ProviderAuthentication"
        if include_associations
          belongs_to :resource_owner, polymorphic: true, inverse_of: :authentications
          belongs_to :provider_authentication, class_name: provider_authentication_class_name

          accepts_nested_attributes_for :provider_authentication
        end

        scope :expired, -> { where('expiration <= ?', Time.now.to_i) }
        scope :unexpired, -> { where('expiration > ?', Time.now.to_i) }

        %i(resource_owner_class password username token_id token client_secret).each do |key|
          attr_accessor key
        end

        validates_presence_of  :auth_type
        validates_inclusion_of :auth_type,     in: %w(password assertion registration)
        validates_presence_of  :client_id
        validates_presence_of  :client_secret, on: :create
        validates_presence_of  :resource_owner
        validates_presence_of  :expiration
        validates_presence_of  :issued_at
        validates_presence_of  :auth_type

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
          if client.blank?
            errors.add :client_id, :invalid
          elsif client.secret != client_secret
            errors.add :client_secret, :invalid
          end
        end

        before_create do
          generate_token_id
          generate_token
          hash_token_id
          true
        end

        class << self
          def for_token token
            begin
              payload = JWT.decode(token, Configuration.jwt.secret).first
              authentication = where(hashed_token_id: hash_token_id(payload['jti'])).first
              authentication if authentication.present? && authentication.valid_payload?(payload)
            rescue JWT::VerificationError => e
              Rails.logger.error "[Rockauth] Possible Forgery Attempt: #{e}"
              nil
            rescue JWT::DecodeError
              nil
            end
          end

          def hash_token_id jti
            Digest::SHA2.hexdigest jti
          end
        end
      end
    end
  end
end
