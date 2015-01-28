class Receptor < ActiveRecord::Base
  
  belongs_to :comprobante

=begin  
  validates :rfc, presence: true
=end
   
  def to_s
    
    "#{self.rfc} #{self.nombre}"
    
  end
  
  def direccion_html
    
    dir = "#{self.domicilio_calle}"
    dir += " #{self.domicilio_noExterior}" if self.domicilio_noExterior
    dir += " #{self.domicilio_noInterior}" if self.domicilio_noInterior
    dir += " #{self.domicilio_colonia}," if self.domicilio_colonia
    dir += " #{self.domicilio_codigoPostal}" if self.domicilio_codigoPostal
    dir += " #{self.domicilio_municipio}," if self.domicilio_municipio
    dir += " #{self.domicilio_estado}" if self.domicilio_estado
    dir += " #{self.domicilio_pais}" if self.domicilio_pais
    
    return dir
    
  end
    
end
