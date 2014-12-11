class AddComprobanteToNotification < ActiveRecord::Migration
  def change
    add_reference :notifications, :comprobante, index: true
  end
end
