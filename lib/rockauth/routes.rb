module Rockauth
  module Routes
    def rockauth resource_owner_class_name, registration: true, password_reset: true, name: nil
      name ||= resource_owner_class_name.constantize.model_name.param_key
      # this scope should prevent anyone from munging parameters and getting to the controllers without a proper resource_owner_class_name
      scope resource_owner_class_name: resource_owner_class_name, module: 'rockauth' do
        Rockauth::Configuration.controller_mappings[resource_owner_class_name.to_s] = { registration: registration, password_reset: password_reset }.freeze
        get    :authentications, controller: 'authentications', action: 'index',        as: :"#{name}_authentications"
        post   :authentications, controller: 'authentications', action: 'authenticate', as: :"create_#{name}_authentication"
        delete :authentications, controller: 'authentications', action: 'destroy',      as: :"destroy_current_#{name}_authentication"

        get    'authentications/:id', controller: 'authentications', action: 'show',    as: :"#{name}_authentication"
        delete 'authentications/:id', controller: 'authentications', action: 'destroy', as: :"destroy_#{name}_authentication"
        me_actions = %i{show create update destroy}

        me_actions -= %i{create} unless registration

        resource  :me, only: me_actions, controller: 'me', as: :"#{name}_me"
        resources :provider_authentications, controller: 'provider_authentications', as: :"#{name}_provider_authentications"

        if password_reset
          post 'passwords/forgot', controller: 'passwords', action: 'forgot', as: :"forgot_#{name}_password"
          post 'passwords/reset',  controller: 'passwords', action: 'reset',  as: :"reset_#{name}_password"
        end
      end
    end
  end
end
