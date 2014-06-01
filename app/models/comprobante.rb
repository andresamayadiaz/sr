class Comprobante < ActiveRecord::Base
  
  has_one :emisor, :dependent => :destroy
  has_one :receptor, :dependent => :destroy
  
  has_attached_file :xml,
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:filename"
  
  before_save :procesar
  after_save :prevalida_cfd
  
  validates_attachment :xml, :presence => true,
    :content_type => { :content_type => ["text/plain", "text/xml"] },
    :size => { :in => 0..900.kilobytes }
    
=begin
  validates :version, presence: true
  validates :fecha, presence: true
  validates :sello, presence: true
  validates :formaDePago, presence: true
  validates :noCertificado, presence: true
  validates :certificado, presence: true
  validates :subTotal, presence: true
  validates :total, presence: true
  validates :tipoDeComprobante, presence: true
  validates :metodoDePago, presence: true
  validates :lugarExpedicion, presence: true
  validates :emisor, presence: true
  validates :receptor, presence: true
=end
    
    def prevalida_cfd
      
      # despues de guardar enviar la solicitud de procesar el comprobante
      
      
    end
    
    def cadena_original
      
      
      
    end
    
  private
    def procesar
      
      logger.debug "=================== Comprobante.procesar ==================="
      logger.debug self.xml.queued_for_write[:original].path
      logger.debug "=================== Comprobante.procesar ==================="
      
      doc = Nokogiri::XML( File.read(self.xml.queued_for_write[:original].path) )
      @version = doc.root.xpath("//cfdi:Comprobante").attribute("version").to_s
      
      if @version == '3.2'
        
        file = COMPROBANTEFACTORY::Cfdi32.new(doc)
        
        # Atributos Requeridos de un CFDv3.2
        self.version = file.version
        self.fecha = file.fecha
        self.sello = file.sello
        self.certificado = file.certificado
        self.tipoDeComprobante = file.tipoDeComprobante
        self.formaDePago = file.formaDePago
        self.noCertificado = file.noCertificado
        self.subTotal = file.subTotal
        self.total = file.total
        self.metodoDePago = file.metodoDePago
        self.lugarExpedicion = file.lugarExpedicion
        
        # Emisor
        self.emisor = Emisor.new(file.emisor.instance_values)
        logger.debug self.emisor.inspect
        
        # Receptor
        self.receptor = Receptor.new(file.receptor.instance_values)
        logger.debug self.receptor.to_json
        
      else
        
        # version no soportada, nula o no es un CFD
        #TODO generar notificacion de comprobante erroneo
        logger.debug "xxxxx Version No Soportada xxxxx"
        return false
        
      end
      
    end
  
end