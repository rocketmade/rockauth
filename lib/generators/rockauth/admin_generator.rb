module Rockauth
  class AdminGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    def copy_admin_templates
      require 'activeadmin'
      template 'resource_owner_admin.rb', 'app/admin/users.rb'
      template 'authentication_admin.rb', 'app/admin/authentications.rb'
      template 'provider_authentication_admin.rb', 'app/admin/provider_authentications.rb'
    rescue LoadError
      puts 'ActiveAdmin is not present, skipping admin pages'
    end

  end
end
