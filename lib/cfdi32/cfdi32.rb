# aad mayo 2014
require 'comprobantefactory'

module COMPROBANTEFACTORY
  
  # Clase Cfdi32 para comprobnates CFDI version 3.2
  #
  class Cfdi32 < COMPROBANTEFACTORY::Comprobante
    
    def initialize(file)
      
      @file = file
      doc = Nokogiri::XML( File.read(@file) )
      @version = doc.root.xpath("//cfdi:Comprobante").attribute("version").to_s
      
      if @version != "3.2" 
        return nil
      end
        
      @fecha = doc.root.xpath("//cfdi:Comprobante").attribute("fecha").to_s
      @sello = doc.root.xpath("//cfdi:Comprobante").attribute("sello").to_s
      @certificado = doc.root.xpath("//cfdi:Comprobante").attribute("certificado").to_s
      
    end
    
  end
  
end