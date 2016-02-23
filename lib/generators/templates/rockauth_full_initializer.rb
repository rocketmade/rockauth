Rockauth.configure do |config|
  # config.allowed_password_length = 8..72
  # config.email_regexp = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  # config.token_time_to_live = 365 * 24 * 60 * 60
  # config.clients = []
  # config.resource_owner_class = 'Rockauth::User'
  # config.warn_missing_social_auth_gems = true
  # config.jwt.issuer = ''
  # config.jwt.signing_method = 'HS256'
  # config.implicit_social_registration = true

  config.jwt.secret              = '<%= SecureRandom.base64(32) %>'
  config.authentication_class = '::Authentication'

  config.serializers.user                    = '::UserSerializer'
  config.serializers.authentication          = '::AuthenticationSerializer'
  config.serializers.provider_authentication = '::ProviderAuthenticationSerializer'
  config.serializers.error                   = '::ErrorSerializer'

  # config.generate_active_admin_resources = nil # nil decides based on whether active_admin is loaded
  # config.active_admin_menu_name = 'User Authentication'
  # config.password_reset_token_time_to_live = 24.hours
  config.email_from = 'change-me-in-config-initializers-rockauth-rb@please-change-me.example'
  # config.forgot_password_always_successful = false

  # config.filter_include = -> controller, is_collection do # Pass include from params to render for active model serializers. Default is only to pass nil
  #   controller.params[:include]
  # end

  config.session_client = config.clients.find { |c| c.title == 'default' }
  # config.session_layout = -> (scope) { Hash.new('application').merge!('admin_user' => 'active_admin_logged_out')[scope] }


  begin
    Array(YAML.load_file(Rails.root.join('config/rockauth_clients.yml'))[Rails.env]).each do |client_config|
      config.clients << Rockauth::Client.new(*(%w(id secret title).map { |k| client_config["client_#{k}"] }))
    end
  rescue Errno::ENOENT
    warn 'Could not load Rockauth clients from config/rockauth_clients.yml'
  end

  begin
    parsed_json = JSON.parse(File.read(Rails.root.join('config/rockauth_providers.json')))[Rails.env] || {}
    OpenStruct.new(parsed_json.with_indifferent_access)
  rescue Errno::ENOENT
    warn 'Could not load Rockauth providers from config/rockauth_providers.json'
  end

  Instagram.configure do |instagram_config|
    instagram_config.client_id     = config.providers.instagram[:client_id]
    instagram_config.client_secret = config.providers.instagram[:client_secret]
  end
end
