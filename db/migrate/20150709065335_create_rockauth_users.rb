class CreateRockauthUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.timestamps null: false
    end
    execute "CREATE UNIQUE INDEX index_users_on_lower_email ON users (lower(email))"
  end

  def down
    drop_table :users
  end
end
