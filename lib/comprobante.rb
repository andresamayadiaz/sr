# aad mayo 2014

# Y quiero que los strings no tengan espacios extraños
class String

  # Limpia whitespace de extremos y espacios repetidos
  # 
  # @return [String] Una copia del string sin espacios extraños
  def squish
    dup.squish!
  end

  # Lo mismo que squish, pero destructivo
  # 
  # @return [String] El string original sin espacios extraños
  def squish!
    strip!
    gsub!(/\s(\s+)/, ' ')
    self
  end

end

module COMPROBANTE
  
  require 'nokogiri'
  #require 'time'
  #require 'base64'
  
  class Comprobante
    
    def self.version
      @version
    end
    
    def self.fecha
      @fecha
    end
    
    def self.sello
      @sello
    end
    
    def self.formaDePago
      @formaDePago
    end
    
    def self.noCertificado
      @noCertificado
    end
    
    def self.certificado
      @certificado
    end
    
    def self.subTotal
      @subTotal
    end
    
    def self.total
      @total
    end
    
    def self.tipoDeComprobante
      @tipoDeComprobante
    end
    
    def self.metodoDePago
      @metodoDePago
    end
    
    def self.lugarExpedicion
      @lugarExpedicion
    end
    
    def self.emisor
      @emisor
    end
    
    def self.receptor
      @receptor
    end
    
    def self.conceptos
      @conceptos
    end
    
  end
  
end