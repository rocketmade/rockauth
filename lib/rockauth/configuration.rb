module Rockauth
  Configuration = Struct.new(*%i(allowed_password_length email_regexp token_time_to_live clients
                                 resource_owner_class warn_missing_social_auth_gems providers jwt
                                 serializers generate_active_admin_resources active_admin_menu_name error_renderer
                                 password_reset_token_time_to_live email_from forgot_password_always_successful
                                 controller_mappings)) do
    def resource_owner_class= arg
      @constantized_resource_owner_class = nil
      @resource_owner_class = arg
    end
    def resource_owner_class
      @constantized_resource_owner_class ||= (@resource_owner_class.respond_to?(:constantize) ?  @resource_owner_class.constantize : @resource_owner_class)
    end
  end.new.tap do |config|
    config.allowed_password_length = 8..72
    config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
    config.token_time_to_live = 365 * 24 * 60 * 60
    config.clients = []
    config.resource_owner_class = 'Rockauth::User'
    config.warn_missing_social_auth_gems = true

    config.providers = Struct.new(*%i(twitter instagram google_plus)).new.tap do |providers|
      %i(twitter instagram google_plus).each do |provider|
        providers.public_send("#{provider}=", {})
      end
    end

    config.jwt = Struct.new(*%i(secret issuer signing_method)).new.tap do |jwt_config|
      jwt_config.secret = ''
      jwt_config.issuer = ''
      jwt_config.signing_method = 'HS256'
    end

    config.serializers = Struct.new(*%i(error user authentication provider_authentication)).new.tap do |serializers|
      serializers.error                   = "Rockauth::ErrorSerializer"
      serializers.user                    = "Rockauth::UserSerializer"
      serializers.authentication          = "Rockauth::AuthenticationSerializer"
      serializers.provider_authentication = "Rockauth::ProviderAuthenticationSerializer"
    end

    config.generate_active_admin_resources = nil
    config.active_admin_menu_name = 'Authentication'
    config.password_reset_token_time_to_live = 24.hours
    config.email_from = 'change-me-in-config-initializers-rockauth-rb@please-change-me.example'
    config.forgot_password_always_successful = false
    config.controller_mappings = {}

    config.error_renderer = -> error do
      { json: error, serializer: Rockauth::Configuration.serializers.error.safe_constantize, status: error.status_code }
    end
  end

  def self.configure
    yield Configuration if block_given?
    Configuration
  end
end
