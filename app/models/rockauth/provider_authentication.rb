require 'active_record'

module Rockauth
  class ProviderAuthentication < ActiveRecord::Base
    self.table_name = 'provider_authentications'
    belongs_to :user, class_name: "Rockauth::User"

    include ProviderValidationConcern

    validates_presence_of   :user
    validates_uniqueness_of :provider_user_id, scope: :provider
    validates_presence_of   :provider
    validates_presence_of   :provider_user_id
    validates_presence_of   :provider_access_token

    validate do
      %i(user_id provider provider_user_id).each do |key|
        errors.add key, :rockauth_cannot_be_changed if !new_record? && public_send(:"#{key}_changed?")
      end
    end

    def self.for_authentication provider: , provider_access_token: , provider_access_token_secret: nil
      auth = ProviderAuthentication.new(provider: provider, provider_access_token: provider_access_token, provider_access_token_secret: provider_access_token_secret)
      auth.configure_from_provider
      auth.exchange
    end

    def exchange
      if provider_user_id.present? && provider.present?
        result = ProviderAuthentication.where(provider: provider, provider_user_id: provider_user_id).first
        result.provider_user_information = provider_user_information
        result.assign_attributes_from_provider
      end
      result ||= self
      result
    end
  end
end
