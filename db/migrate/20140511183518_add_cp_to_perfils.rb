class AddCpToPerfils < ActiveRecord::Migration
  def change
    add_column :perfils, :cp, :string
  end
end
