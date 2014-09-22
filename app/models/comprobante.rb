class Comprobante < ActiveRecord::Base
  
  belongs_to :user
  has_one :emisor, :dependent => :destroy
  has_one :receptor, :dependent => :destroy
  has_one :TimbreFiscalDigital, :dependent => :destroy
  before_create :set_internal_uuid
  
  has_attached_file :xml,
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:filename"
  
  # Tags
  acts_as_taggable
  
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
      
      # TODO validar si es emitido que el RFC y datos ficales del emisor coincidan con el perfil
      # TODO validar si es recibido que el RFC y datos fiscales del receptor coincidan con el perfil
      
    end
    
    def valida_cfd
      
      # despues de pasar la prevalidacion se debe validar
      # TODO validar contra el esquema XSLT
      # TODO con el certificado, cadena original y sello validar openssl_verify
      
    end
    
    def to_s
      
      str = ""
      # UUID [a-f0-9A-F]{8}-[a-f0-9A-F]{4}-[a-f0-9A-F]{4}-[a-f0-9A-F]{4}-[a-f0-9A-F]{12}
      # TODO implementar algo mas amigable
      if version == '3.2'
        #"#{self.TimbreFiscalDigital.UUID},#{self.serie}#{self.folio}"
        if !self.TimbreFiscalDigital.nil?
          if !self.TimbreFiscalDigital.uuid.nil?
            str += self.TimbreFiscalDigital.uuid
          end
        end
        if !self.serie.nil?
          str += " "+self.serie
        end
        if !self.folio.nil?
          str += "-"+self.folio
        end
        return str
      else
        super
      end
      
    end
    
    # XSLT not working with version 2.0, we manually changed xslt files to version 1.0
    def cadena_original
      
      return self.xml_obj.cadena_original
      
    end
    
    def xml_obj
      
      # TODO validar si ya cargo el objeto no volverlo a cargar cada que se mande llamar
      
      doc = Nokogiri::XML( File.read(self.xml.path) )
      @version = doc.root.xpath("//cfdi:Comprobante").attribute("version").to_s
      
      if @version == '3.2'
        return COMPROBANTEFACTORY::Cfdi32.new(doc)
      else
        raise "Version #{@version} No Soportada"
      end
      
    end
    
  private
    
    # Generar un UUID interno al comprobante para uso futuro
    def set_internal_uuid
      self.internal_uuid = SecureRandom.uuid
    end
    
    def procesar
      
      if !self.version.blank?
        # Se esta haciendo un save a un comprobante previamente guardado,
        # probablemente se este actualizando el tags_list
        logger.debug "Comprobante Already Exists!"
        return
      end
      
      logger.debug "=================== Comprobante.procesar ==================="
      logger.debug self.xml.queued_for_write[:original].path
      logger.debug "=================== /Comprobante.procesar ==================="
      
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
          self.serie = file.serie
          self.folio = file.folio
          
          # Emisor
          self.emisor = Emisor.new(file.emisor.instance_values)
          logger.debug self.emisor.to_json
          if self.emisor.rfc == self.user.rfc
            self.emitido = true
          end
          
          # Receptor
          self.receptor = Receptor.new(file.receptor.instance_values)
          logger.debug self.receptor.to_json
          if self.receptor.rfc == self.user.rfc
            self.recibido = true
          end
          
          # Timbre Fiscal Digital
          timbre_values = file.timbre.instance_values.tap{|x| x.delete("doc")}
          self.TimbreFiscalDigital = TimbreFiscalDigital.new(timbre_values)
          logger.debug self.TimbreFiscalDigital.to_json
          #logger.debug file.timbre.to_json
          
        else
        
          # version no soportada, nula o no es un CFD
          # TODO generar notificacion de comprobante erroneo
          logger.debug "============ Version No Soportada ============"
          raise "Version #{@version} No Soportada"
        
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
