class AddComprobanteToReceptor < ActiveRecord::Migration
  def change
    add_reference :receptors, :comprobante, index: true
  end
end
