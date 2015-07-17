module Rockauth
  class ModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    def install_models
      template 'user.rb', 'app/models/user.rb'
      invoke 'active_record:model', ['authentication'], parent: 'Rockauth::Authentication', migrate: false
      invoke 'active_record:model', ['provider_authentication'], parent: 'Rockauth::ProviderAuthentication', migrate: false
    end
  end
end
