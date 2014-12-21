class Notification < ActiveRecord::Base
  belongs_to :comprobante
  belongs_to :user

  scope :warnings, -> { where(category: 'Warning') }
  scope :errors, -> { where(category: 'Error') }
end
