class AddValidationCategoryFieldsToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :validation, :string
    add_column :notifications, :category, :string
  end
end
