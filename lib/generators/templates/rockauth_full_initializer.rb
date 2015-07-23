Rockauth.configure do |config|
  # config.allowed_password_length = 8..72
  # config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  # config.token_time_to_live = 365 * 24 * 60 * 60
  # config.clients = []
  # config.resource_owner_class = 'Rockauth::User'
  # config.warn_missing_social_auth_gems = true
  # config.jwt.issuer = ''
  # config.jwt.signing_method = 'HS256'

  config.jwt.secret              = "<%= SecureRandom.base64(32) %>"
  config.resource_owner_class    = '::User'
  config.twitter.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
  config.twitter.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']

  begin
    Array(YAML.load_file(Rails.root.join('config/rockauth_clients.yml'))[Rails.env]).each do |client_config|
      config.clients << Rockauth::Client.new(*(%w(id secret title).map { |k| client_config["client_#{k}"] }))
    end
  rescue Errno::ENOENT
    warn 'Could not load Rockauth clients from config/rockauth_clients.yml'
  end

end

Instagram.configure do |config|
  config.client_id     = ENV['INSTAGRAM_CLIENT_ID']
  config.client_secret = ENV['INSTAGRM_CLIENT_SECRET']
end

GooglePlus.api_key = ENV['GOOGLE_PLUS_API_KEY']
