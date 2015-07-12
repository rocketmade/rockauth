module Rockauth
  class ModelsGenerator < Rails::Generators::Base
    def install_models
      invoke "active_record:model", ["user"], parent: "Rockauth::User", migrate: false
      invoke "active_record:model", ["authentication"], parent: "Rockauth::Authentication", migrate: false
      invoke "active_record:model", ["provider_authentication"], parent: "Rockauth::ProviderAuthentication", migrate: false
    end
  end
end
