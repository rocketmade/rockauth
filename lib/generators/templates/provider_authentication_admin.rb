ActiveAdmin.register ProviderAuthentication, as: "ProviderAuthentication" do
  menu parent: Rockauth::Configuration.active_admin_menu_name

  actions :all, except: %i(new create edit update)


  index do
    id_column
    column :resource_owner
    column :provider
    column :provider_user_id
    column :created_at
    actions
  end

  show do
    attributes_table do
      (resource.attribute_names.map(&:to_sym) - %i(provider_access_token provider_access_token_secret)).each do |key|
        row key
      end
    end
    active_admin_comments
  end
end
