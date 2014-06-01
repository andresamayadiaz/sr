class ChangePrecisionInComprobantes < ActiveRecord::Migration
  def change
    change_column :comprobantes, :subTotal, :decimal, :precision => 17, :scale => 6, :default => '0'
    change_column :comprobantes, :total, :decimal, :precision => 17, :scale => 6, :default => '0'
  end
end
