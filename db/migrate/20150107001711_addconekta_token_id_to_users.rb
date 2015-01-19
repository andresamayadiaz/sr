class AddconektaTokenIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :conektaTokenId, :string
  end
end
