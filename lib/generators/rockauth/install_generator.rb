require_relative './client_generator.rb'
module Rockauth
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    desc 'Installs Rockauth'

    def copy_initializer
      copy_file 'rockauth_full_initializer.rb', 'config/initializers/rockauth.rb'
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

    def install_route
      route 'mount Rockauth::Engine => "/"'
    end

    def generate_development_client
      invoke 'rockauth:client', ['Default Client'], environment: 'development'
    end

    def declare_dependencies
      gem 'fb_graph2'
      gem 'twitter'
      gem 'google_plus'
      gem 'instagram'
    end
  end
end
