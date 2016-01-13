module Rockauth
  module Routes
    def rockauth resource_owner_class_name, registration: true, password_reset: true
      # this scope should prevent anyone from munging parameters and getting to the controllers without a proper resource_owner_class_name
      scope resource_owner_class_name: resource_owner_class_name, module: 'rockauth' do
        Rockauth::Configuration.controller_mappings[resource_owner_class_name.to_s] = { registration: registration, password_reset: password_reset }.freeze
        get    :authentications, controller: 'authentications', action: 'index'
        post   :authentications, controller: 'authentications', action: 'authenticate'
        delete :authentications, controller: 'authentications', action: 'destroy'

        delete 'authentications/:id', controller: 'authentications', action: 'destroy'
        me_actions = %i{show create update destroy}

        me_actions -= %i{create} unless registration

        resource :me, only: me_actions, controller: 'me'
        resources :provider_authentications, controller: 'provider_authentications'

        if password_reset
          post 'passwords/forgot', controller: 'passwords', action: 'forgot'
          post 'passwords/reset', controller: 'passwords', action: 'reset'
        end
      end
    end
  end
end
