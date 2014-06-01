class AddComprobanteToEmisor < ActiveRecord::Migration
  def change
    add_reference :emisors, :comprobante, index: true
  end
end
