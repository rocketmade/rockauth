class AddIssuedAtToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :issued_at, :integer
  end
end
