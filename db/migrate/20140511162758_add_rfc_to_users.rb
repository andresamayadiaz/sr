class AddRfcToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rfc, :string
    add_index :users, :rfc, unique: true
  end
end
