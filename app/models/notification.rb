class Notification < ActiveRecord::Base
  belongs_to :comprobante
  belongs_to :user
end
