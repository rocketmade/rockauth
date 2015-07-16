Rockauth.configure do |config|
  # config.allowed_password_length = 8..72
  # config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  # config.token_time_to_live = 365 * 24 * 60 * 60
  # config.clients = []
  # config.warn_missing_social_auth_gems = true
  config.resource_owner_class = '::User'
end
