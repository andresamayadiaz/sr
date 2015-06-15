class Emisor < ActiveRecord::Base

  belongs_to :comprobante, dependent: :destroy

=begin
  validates :rfc, presence: true
  validates :regimenFiscal, presence: true
=end
  
  def to_s
    
    "#{self.rfc} #{self.nombre}"
    
  end
  
  def direccion_html
    
    dir = "#{self.domicilio_calle}"
    dir += " #{self.domicilio_noExterior}" if self.domicilio_noExterior
    dir += " #{self.domicilio_noInterior}<br />" if self.domicilio_noInterior
    dir += " #{self.domicilio_colonia}" if self.domicilio_colonia
    dir += " #{self.domicilio_municipio}<br />" if self.domicilio_municipio
    dir += " #{self.domicilio_estado}" if self.domicilio_estado
    dir += " #{self.domicilio_pais}" if self.domicilio_pais
    dir += " <br/>C.P. #{self.domicilio_codigoPostal}" if self.domicilio_codigoPostal
    
    return dir
    
  end
  
end