module Rockauth
  module Models::ProviderValidation
    extend ActiveSupport::Concern
    attr_accessor :provider_user_information

    included do
      validates_inclusion_of :provider, in: ->(instance) { instance.class.valid_networks }

      before_validation :configure_from_provider

      def configure_from_provider
        if provider.present? && self.class.valid_networks.include?(provider)
          self.provider_user_information = instance_exec &self.class.network_validator(provider)
          assign_attributes_from_provider
        end

        true
      end

      def assign_attributes_from_provider
        return unless provider_user_information.present?
        self.provider_user_id = provider_user_information.user_id
      end

      { facebook: 'fb_graph2', instagram: 'instagram', twitter: 'twitter', google_plus: 'google_plus' }.each do |key, value|
        begin
          require value
          provider_network key do
            ProviderUserInformation.for_provider(provider, provider_access_token, provider_access_token_secret)
          end
        rescue LoadError
          if Rockauth::Configuration.warn_missing_social_auth_gems
            warn "Rockauth: Could not load the #{value} gem, #{key.to_s.humanize} provider authentication disabled"
          end
        end
      end
    end


    module ClassMethods
      def provider_network provider, &block
        fail ArgumentError, "no block given" unless block_given?
        @network_validator_configuration ||= {}
        @network_validator_configuration[provider.to_s] = block
      end

      def valid_networks
        @network_validator_configuration.keys
      end

      def network_validator provider
        @network_validator_configuration[provider.to_s]
      end
    end
  end
end
