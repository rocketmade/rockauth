module Rockauth
  def self.configure
    yield Configuration if block_given?
    Configuration
  end

  Configuration = Struct.new(*%i(allowed_password_length email_regexp token_time_to_live clients)).new.tap do |config|
    config.allowed_password_length = 8..72
    config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
    config.token_time_to_live = 365 * 24 * 60 * 60
    config.clients = []
  end
end
