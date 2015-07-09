class CreateRockauthProviderAuthentications < ActiveRecord::Migration
  def change
    create_table :provider_authentications do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider, null: false
      t.string :provider_user_id, null: false, index: true
      t.string :provider_access_token, null: false
      t.string :provider_access_token_secret
      t.string :provider_key, null: false, default: 'default'

      t.timestamps null: false
    end

    add_index :provider_authentications, [:provider, :provider_user_id], unique: true
  end
end
