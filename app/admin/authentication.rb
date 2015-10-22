ActiveAdmin.register Rockauth::Configuration.resource_owner_class.reflections['authentications'].klass, as: "Authentication" do
  menu parent: Rockauth::Configuration.active_admin_menu_name

  actions :all, except: %i(new create edit update)

  index do
    id_column
    column :auth_type
    column :client
    column :device_os

    column :expiration do |r|
      Time.at(r.expiration).to_formatted_s(:rfc822) if r.expiration.present?
    end

    column :issued_at do |r|
      Time.at(r.issued_at).to_formatted_s(:rfc822) if r.issued_at.present?
    end
    actions
  end

  show do
    attributes_table do
      row :expiration do |r|
        Time.at(r.expiration).to_formatted_s(:rfc822) if r.expiration.present?
      end

      row :issued_at do |r|
        Time.at(r.issued_at).to_formatted_s(:rfc822) if r.issued_at.present?
      end
      (resource.attribute_names.map(&:to_sym) - %i(hashed_token_id expiration issued_at)).each do |key|
        row key
      end
    end
    active_admin_comments
  end
end
