class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :max_uploaded
      t.decimal :price
      t.timestamps
    end
  end
end
