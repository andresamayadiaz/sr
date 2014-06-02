class AddUserToComprobantes < ActiveRecord::Migration
  def change
    add_reference :comprobantes, :user, index: true
  end
end
