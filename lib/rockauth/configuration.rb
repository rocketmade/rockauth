module Rockauth
  Configuration = Struct.new(*%i(allowed_password_length email_regexp token_time_to_live clients resource_owner_class warn_missing_social_auth_gems twitter jwt)) do
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
    config.twitter = Struct.new(:consumer_key, :consumer_secret).new

    config.jwt = Struct.new(*%i(secret issuer signing_method)).new.tap do |jwt_config|
      jwt_config.secret = ''
      jwt_config.issuer = nil
      jwt_config.signing_method = 'HS256'
    end
  end

  def self.configure
    yield Configuration if block_given?
    Configuration
  end
end
