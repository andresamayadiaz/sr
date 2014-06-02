class Comprobante < ActiveRecord::Base
  
  has_one :emisor, :dependent => :destroy
  has_one :receptor, :dependent => :destroy
  belongs_to :user
  
  has_attached_file :xml,
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:filename"
  
  before_save :procesar
  
  validates_attachment :xml, :presence => true,
    :content_type => { :content_type => ["text/plain", "text/xml"] },
    :size => { :in => 0..900.kilobytes }
    
  default_scope { order('created_at DESC') }
    
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
      
      # despues de actualizar enviar la solicitud de procesar el comprobante
      # TODO validar que exista el rfc del emisor y receptor de lo contrario devuelve error
      emitido = false
      recibido = false
      
      if self.emisor
        if self.emisor.rfc == self.user.rfc
          emitido = true
        end
      end
      
      if self.receptor
        if self.receptor.rfc == self.user.rfc
          recibido = true
        end
      end
      
      # TODO validar si ambos emitido y recibido son false ponerlo en categoria de externo ???
      
      self.update_columns(:emitido => emitido, :recibido => recibido)
      
    end
    
    def valida_cfd
      
      # despues de pasar la prevalidacion se debe validar
      # TODO validar contra el esquema XSLT
      # TODO con el certificado, cadena original y sello validar openssl_verify
      
    end
    
    def to_s
      
      # TODO implementar algo mas amigable
      super
      
    end
    
    # TODO XSLT not working with version 2.0
    def cadena_original
      
      doc = Nokogiri::XML( File.read(self.xml.path) )
      @version = doc.root.xpath("//cfdi:Comprobante").attribute("version").to_s
      
      if @version == '3.2'
      
        file = COMPROBANTEFACTORY::Cfdi32.new(doc)
        file.cadena_original
        
      else
        
        logger.debug "============ Version No Soportada ============"
        return nil
        
      end
      
    end
    
  private
    def procesar
      
      logger.debug "=================== Comprobante.procesar ==================="
      logger.debug self.xml.queued_for_write[:original].path
      logger.debug "=================== Comprobante.procesar ==================="
      
      begin
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
          # TODO generar notificacion de comprobante erroneo
          logger.debug "============ Version No Soportada ============"
          return false
        
        end
      
    # Archivo No Compatible
    rescue Exception => e
      
      # TODO generar notificacion de comprobante erroneo
      logger.warn "============ Archivo Invalido ============"
      logger.warn e.message
      logger.warn e.backtrace.inspect
      logger.warn "============ /Archivo Invalido ============"
      return false
      
    end
      
    end
  
end
