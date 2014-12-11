class AddInvoiceFileNameToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :invoice_file_name, :string
  end
end
