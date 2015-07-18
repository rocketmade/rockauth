require 'securerandom'

module Rockauth
  class ClientGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../../templates', __FILE__)
    desc "Generate a rockauth client"

    class_option :environment,  default: 'production',       desc: 'Environment for the client'

    def generate_client
      client_id = SecureRandom.urlsafe_base64(16)
      client_secret = SecureRandom.urlsafe_base64(32)

      file_path = Rails.root.join("config/rockauth_clients.yml")
      environments = {}

      if File.exists?(file_path)
        environments = YAML.load_file(file_path)
      end

      environments[options[:environment]] ||= []
      environments[options[:environment]] << {
        'client_id' => client_id,
        'client_title' => name,
        'client_secret' => client_secret
      }

      File.open(file_path, 'wb') do |file|
        file.write environments.stringify_keys.to_yaml(cannonical: false).gsub(/\A---\n/, '')
      end
    end
  end
end
