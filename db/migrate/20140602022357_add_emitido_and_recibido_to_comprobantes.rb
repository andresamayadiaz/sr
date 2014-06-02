class AddEmitidoAndRecibidoToComprobantes < ActiveRecord::Migration
  def change
    add_column :comprobantes, :emitido, :boolean, :default => false
    add_index :comprobantes, :emitido
    add_column :comprobantes, :recibido, :boolean, :default => false
    add_index :comprobantes, :recibido
  end
end
