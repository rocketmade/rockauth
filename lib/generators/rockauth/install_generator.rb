require_relative './client_generator.rb'
module Rockauth
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    desc 'Installs Rockauth'

    def copy_initializer
      template 'rockauth_full_initializer.rb', 'config/initializers/rockauth.rb'
    end

    def copy_locales
      copy_file '../../../config/locales/en.yml', 'config/locales/rockauth.en.yml'
    end

    def copy_clients
      copy_file 'rockauth_clients.yml', 'config/rockauth_clients.yml'
    end

    def generate_models
      invoke 'rockauth:models'
    end

    def generate_migrations
      invoke 'rockauth:migrations'
    end

    def generate_serializers
      puts File.expand_path('../../../app/serializers/rockauth/*.rb', File.dirname(__FILE__))
      Dir[File.expand_path('../../../app/serializers/rockauth/*.rb', File.dirname(__FILE__))].each do |f|
        basename = File.basename(f)
        copy_file f, "app/serializers/#{basename}"
        gsub_file "app/serializers/#{basename}", 'module Rockauth', ''
        gsub_file "app/serializers/#{basename}", /^end$/, ''
        gsub_file "app/serializers/#{basename}", /^\s\s/, ''
      end
    end

    def install_route
      route <<ROUTE
scope '/api' do
    rockauth 'User', registration: false, password_reset: true
  end
ROUTE
    end

    def generate_development_client
      invoke 'rockauth:client', ['Default Client'], environment: 'development'
    end

    def declare_dependencies
      gem 'fb_graph2'
      gem 'twitter'
      gem 'google_plus'
      gem 'instagram'
      gem 'active_model_serializers', '~> 0.8.3'
    end
  end
end
