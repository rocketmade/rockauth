require 'active_record'

module Rockauth
  class ProviderAuthentication < ActiveRecord::Base
    self.table_name = 'provider_authentications'
    belongs_to :resource_owner, polymorphic: true, inverse_of: :provider_authentications

    include Models::ProviderValidation

    attr_accessor :authentication

    validates_presence_of   :resource_owner
    validates_uniqueness_of :provider_user_id, scope: :provider
    validates_presence_of   :provider
    validates_presence_of   :provider_user_id
    validates_presence_of   :provider_access_token

    validate :validate_attributes_unchangable

    delegate :resource_owner_class, to: :authentication

    def self.active_model_serializer
      Rockauth::Configuration.serializers.provider_authentication.safe_constantize
    end
    delegate :active_model_serializer, to: :class

    def validate_attributes_unchangable
      %i(resource_owner_id resource_owner_type provider provider_user_id).each do |key|
        errors.add key, :rockauth_cannot_be_changed if !new_record? && public_send(:"#{key}_changed?")
      end
    end

    def exchange
      result = self

      configure_from_provider

      if provider_user_id.present? && provider.present?
        result = self.class.where(provider: provider, provider_user_id: provider_user_id).first
        if result.present?
          result.provider_user_information = provider_user_information
          result.assign_attributes_from_provider
          result
        else
          handle_missing_resource_owner_on_valid_assertion
          result = self
        end
      end

      result
    end

    def handle_missing_resource_owner_on_valid_assertion
      self.resource_owner = resource_owner_class.new
      resource_owner.assign_attributes_from_provider_user(provider_user_information)
      resource_owner.provider_authentications << self
    end
  end
end
