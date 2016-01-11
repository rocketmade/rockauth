class AddPasswordResetTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token, :string, index: true, unique: true
    add_column :users, :password_reset_token_expires_at, :timestamp
  end
end
