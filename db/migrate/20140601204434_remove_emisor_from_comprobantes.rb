class RemoveEmisorFromComprobantes < ActiveRecord::Migration
  def change
    remove_column :comprobantes, :emisor_id
    remove_column :comprobantes, :receptor_id
  end
end
