module Rockauth
  module ResourceOwnerConcern
    extend ActiveSupport::Concern

    included do |sub|
      has_many :provider_authentications, as: :resource_owner, inverse_of: :resource_owner, class_name: 'Rockauth::ProviderAuthentication', dependent: :destroy
      has_many :authentications, as: :resource_owner, inverse_of: :resource_owner, class_name: 'Rockauth::Authentication', dependent: :destroy

      accepts_nested_attributes_for :authentications
      accepts_nested_attributes_for :provider_authentications

      validates_associated :authentications, on: :create
    end
  end
end
