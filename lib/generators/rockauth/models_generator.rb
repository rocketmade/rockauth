module Rockauth
  class ModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    def install_models
      template 'user.rb', 'app/models/user.rb'
      template 'provider_authentication.rb', 'app/models/provider_authentication.rb'
      template 'authentication.rb', 'app/models/authentication.rb'
    end
  end
end
