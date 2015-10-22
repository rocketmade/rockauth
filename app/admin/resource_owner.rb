ActiveAdmin.register Rockauth::Configuration.resource_owner_class, as: "User" do
  menu parent: Rockauth::Configuration.active_admin_menu_name

  controller do
    helper_method :attribute_list
    def attribute_list
      (Rockauth::Configuration.resource_owner_class.attribute_names.map(&:to_sym) - %i(id password_digest created_at updated_at))
    end
  end

  permit_params do
    (attribute_list + %i(password))
  end

  index do
    id_column
    ((attribute_list & %i(email)) + %i(created_at)).each do |key|
      column key
    end
    actions
  end

  show do
    attributes_table do
      (attribute_list + %i{created_at updated_at}).each do |key|
        row key
      end
    end

    panel "Authentications" do
      table_for resource.authentications do
        column :id do |r|
          link_to r.id, admin_user_path(r)
        end
        column :auth_type
        column :client
        column :device_os

        column :expiration do |r|
          Time.at(r.expiration).to_formatted_s(:rfc822) if r.expiration.present?
        end

        column :issued_at do |r|
          Time.at(r.issued_at).to_formatted_s(:rfc822) if r.issued_at.present?
        end

        column do |r|
          text_node link_to('View', admin_authentication_path(r), class: 'member_link')
          text_node link_to('Destroy', admin_authentication_path(r), method: :delete, data: { confirm: 'Are you sure?' }, class: 'member_link')
        end
      end
    end


    panel "Provider Authentications (social authorizations)" do
      table_for resource.provider_authentications do
        column :id do |r|
          link_to r.id # link_to r.id, [:admin, r]
        end
        column :provider
        column :provider_user_id
        column :created_at

        column do |r|
          text_node link_to('View', admin_provider_authentication_path(r), class: 'member_link')
          text_node link_to('Destroy', admin_provider_authentication_path(r), method: :delete, data: { confirm: 'Are you sure?' }, class: 'member_link')
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs (attribute_list + %i(password))
    f.actions
  end
end
