require 'hooks'

module Rockauth
  module Models::ResourceOwner
    extend ActiveSupport::Concern

    included do
      include Hooks
      define_hooks :after_authentication, :before_logout
    end

    def assign_attributes_from_provider_user provider_user_information
    end

    module ClassMethods
      def resource_owner nested_attributes: true, validations: true, authentication_class_name: 'Rockauth::Authentication', provider_authentication_class_name: 'Rockauth::ProviderAuthentication'
        @authentication_class_name = authentication_class_name
        @provider_authentication_class_name = provider_authentication_class_name
        has_many :provider_authentications, as: :resource_owner, inverse_of: :resource_owner, class_name: @provider_authentication_class_name, dependent: :destroy
        has_many :authentications, as: :resource_owner, inverse_of: :resource_owner, class_name: @authentication_class_name, dependent: :destroy

        accepts_nested_attributes_for :authentications
        accepts_nested_attributes_for :provider_authentications

        validates_associated :authentications, on: :create
        # validates_presence_of :authentications, on: :create

        def authentication_class
          @authentication_class_name.safe_constantize
        end

        def provider_authentication_class
          @provider_authentication_class_name.safe_constantize
        end
      end
    end
  end
end
