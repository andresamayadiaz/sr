class AddSerieFolioToComprobante < ActiveRecord::Migration
  def change
    add_column :comprobantes, :serie, :string
    add_column :comprobantes, :folio, :string
  end
end
