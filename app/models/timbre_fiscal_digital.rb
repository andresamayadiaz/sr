class TimbreFiscalDigital < ActiveRecord::Base
  
  belongs_to :comprobante
  
  validates :comprobante, presence: true
  validates :uuid, presence: true
  validates :version, presence: true
  
end
