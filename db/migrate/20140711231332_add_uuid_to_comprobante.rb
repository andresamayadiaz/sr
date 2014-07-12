class AddUuidToComprobante < ActiveRecord::Migration
  def change
    add_column :comprobantes, :internal_uuid, :string
  end
end
