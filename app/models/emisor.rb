class Emisor < ActiveRecord::Base

  belongs_to :comprobante

=begin
  validates :rfc, presence: true
  validates :regimenFiscal, presence: true
=end
  
  def to_s
    
    "#{self.rfc} #{self.nombre}"
    
  end
  
end