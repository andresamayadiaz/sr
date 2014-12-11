class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :description
      t.boolean :status #false means unread
      t.string :email
      t.timestamps
    end
  end
end
