module Rockauth
  def self.configure
    yield Configuration if block_given?
    Configuration
  end

  Configuration = Struct.new(*%i(allowed_password_length email_regexp token_time_to_live clients resource_owner_class)) do
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
  end
end
