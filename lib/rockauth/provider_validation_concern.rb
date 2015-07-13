module Rockauth
  module ProviderValidationConcern
    extend ActiveSupport::Concern
    attr_accessor :provider_user_information

    included do
      validates_inclusion_of :provider, in: ->(instance) { instance.class.valid_networks }

      before_validation do
        if provider.present? && self.class.valid_networks.include?(provider)
          instance_exec &self.class.network_validator(provider)
        end
      end

      { facebook: 'fb_graph', instagram: 'instagram', twitter: 'twitter', google_plus: 'google_plus' }.each do |key, value|
        begin
          require value
          provider_network key do
            @provider_user_information ||= ProviderUserInformation.for_provider(provider, provider_access_token, provider_access_token_secret).tap do |u|
              self.provider_user_id = u.user_id
            end
          end
        rescue LoadError
          Rails.logger.warn "Rockauth: Could not load the #{value} gem, #{key.to_s.humanize} provider authentication disabled"
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
