class CreateRockauthAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :resource_owner, polymorphic: true
      t.references :provider_authentication, index: true, foreign_key: true
      t.integer :expiration
      t.integer :issued_at
      t.string :hashed_token_id
      t.string :auth_type, null: false
      t.string :client_id, null: false
      t.string :client_version
      t.string :device_identifier
      t.string :device_description
      t.string :device_os
      t.string :device_os_version

      t.timestamps null: false
    end

    add_index :authentications, [:resource_owner_id, :resource_owner_type], name: 'index_authentications_on_resource_owner'
    add_index :authentications, :hashed_token_id
  end
end
