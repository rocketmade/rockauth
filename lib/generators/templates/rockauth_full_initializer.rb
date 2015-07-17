Rockauth.configure do |config|
  # config.allowed_password_length = 8..72
  # config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  # config.token_time_to_live = 365 * 24 * 60 * 60
  # config.clients = []
  # config.warn_missing_social_auth_gems = true
  config.resource_owner_class = '::User'

  begin
    Array(YAML.load_file(Rails.root.join('config/rockauth_clients.yml'))[Rails.env]).each do |client_config|
      config.clients << Rockauth::Client.new(*(%w(id secret title).map { |k| client_config[k] }))
    end
  rescue Errno::ENOENT
    warn 'Could not load Rockauth clients from config/rockauth_clients.yml'
  end

end
