module Rockauth
  module Models::ProviderAuthentication
    extend ActiveSupport::Concern

    module ClassMethods
      def provider_authentication include_associations: true, authentication_class_name: 'Rockauth::Authentication'

        if include_associations
          belongs_to :resource_owner, polymorphic: true, inverse_of: :provider_authentications
          has_many :authentications, class_name: authentication_class_name, dependent: :nullify
        end

        attr_accessor :authentication

        validates_presence_of   :resource_owner
        validates_uniqueness_of :provider_user_id, scope: :provider
        validates_presence_of   :provider
        validates_presence_of   :provider_user_id
        validates_presence_of   :provider_access_token

        validate :validate_attributes_unchangable

        delegate :resource_owner_class, to: :authentication

        define_method :validate_attributes_unchangable do
          %i(resource_owner_id resource_owner_type provider provider_user_id).each do |key|
            errors.add key, :rockauth_cannot_be_changed if !new_record? && public_send(:"#{key}_changed?")
          end
        end

        define_method :exchange do
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

        define_method :handle_missing_resource_owner_on_valid_assertion do
          self.resource_owner = resource_owner_class.new
          resource_owner.assign_attributes_from_provider_user(provider_user_information)
          resource_owner.provider_authentications << self
        end
      end
    end
  end
end
