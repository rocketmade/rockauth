class CreateRockauthProviderAuthentications < ActiveRecord::Migration
  def change
    create_table :provider_authentications do |t|
      t.references :resource_owner, polymorphic: true
      t.string :provider, null: false
      t.string :provider_user_id, null: false, index: true
      t.string :provider_access_token, null: false
      t.string :provider_access_token_secret

      t.timestamps null: false
    end

    add_index :provider_authentications, [:provider, :provider_user_id], unique: true
    add_index :provider_authentications, [:resource_owner_id, :resource_owner_type], name: 'index_provider_authentications_on_resource_owner'
  end
end
