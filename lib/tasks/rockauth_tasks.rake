# desc "Explaining what the task does"
# task :rockauth do
#   # Task goes here
# end


namespace :rockauth do
  desc 'Generates a new client id and secret and places it in config/initializers/rockauth.rb'
  task :generate_client do
    require 'securerandom'
    client_id = SecureRandom.urlsafe_base64(16)
    client_secret = SecureRandom.urlsafe_base64(32)
    print 'Enter Client Title []: '
    client_title = $stdin.gets.chomp

    print 'Enter Client Environment [production]: '
    client_environment = $stdin.gets.chomp
    client_environment = 'production' if client_environment.blank?

    file_path = Rails.root.join("config/rockauth_clients.yml")
    environments = {}

    if File.exists?(file_path)
      environments = YAML.load_file(file_path)
    end

    environments[client_environment] ||= []
    environments[client_environment] << {
      'client_id' => client_id,
      'client_title' => client_title,
      'client_secret' => client_secret
    }

    File.open(file_path, 'wb') do |file|
      file.write environments.stringify_keys.to_yaml(cannonical: false).gsub(/\A---\n/, '')
    end
  end
end
