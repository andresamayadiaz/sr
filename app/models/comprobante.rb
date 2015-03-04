class Comprobante < ActiveRecord::Base
  
  belongs_to :user
  has_one :emisor, :dependent => :destroy
  has_one :receptor, :dependent => :destroy
  has_one :TimbreFiscalDigital, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  before_create :set_internal_uuid
  
  has_attached_file :xml,
  :path => ":class/:attachment/:id_partition/:filename",
  :url => "/comprobante/xml/:id"  
  #:url => "/system/:class/:attachment/:id_partition/:filename"
  # Tags
  acts_as_taggable
  
  after_post_process :procesar
  after_create :generate_notifications
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
  
  def self.top_10_clients(current_user_id)
    top_10 = []
    clients = Receptor.joins(:comprobante).where('comprobantes.emitido=? AND comprobantes.user_id=? AND comprobantes.fecha between ? AND ?',true,current_user_id,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group('nombre').sum('comprobantes.total') rescue nil
    if clients.present?
      top_10 = clients.sort_by{|k,v|-v}.first(10).map{|x| x[0]=x[0],x[1]=x[1].to_i}
    end
    top_10
  end
    
  def self.top_10_suppliers(current_user_id)
    top_10 = []
    clients = Emisor.joins(:comprobante).where('comprobantes.recibido=? AND comprobantes.user_id=? AND comprobantes.fecha between ? AND ?',true,current_user_id,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group('nombre').sum('comprobantes.total') rescue nil
    if clients.present?
      top_10 = clients.sort_by{|k,v|-v}.first(10).map{|x| x[0]=x[0],x[1]=x[1].to_i}
    end
    top_10
  end

  def self.sent_invoices(current_user_id)
    invoices = Comprobante.where("user_id=? AND emitido=? AND recibido=? AND fecha between ? AND ?",current_user_id,true,false,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group_by{|i|i.fecha.month}
    sent_invoices = []
    (1..12).each do |i|
      mo = i
      val = invoices[i].length rescue 0
      sent_invoices << [mo,val]
    end
    sent_invoices
  end

  def self.received_invoices(current_user_id)
    invoices = Comprobante.where("user_id=? AND emitido=? AND recibido=? AND fecha between ? AND ?",current_user_id,false,true,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group_by{|i|i.fecha.month}
    rec_invoices = []
    (1..12).each do |i|
      mo = i
      val = invoices[i].length rescue 0
      rec_invoices << [mo,val]
    end
    rec_invoices
  end

  def self.sent_amount(current_user_id)
    invoices = Comprobante.where("user_id=? AND emitido=? AND recibido=? AND fecha between ? AND ?",current_user_id,true,false,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group_by{|i|i.fecha.month}
    sent_amount = []
    (1..12).each do |i|
      mo = i
      val = invoices[i].sum(&:total).to_i rescue 0
      sent_amount << [mo,val]
    end
    sent_amount
  end
  
  def self.received_amount(current_user_id)
    invoices = Comprobante.where("user_id=? AND emitido=? AND recibido=? AND fecha between ? AND ?",current_user_id,false,true,Time.zone.now.beginning_of_year,Time.zone.now.end_of_year).group_by{|i|i.fecha.month}
    rec_amount = []
    (1..12).each do |i|
      mo = i
      val = invoices[i].sum(&:total).to_i rescue 0
      rec_amount << [mo,val]
    end
    rec_amount
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
      logger.debug self.xml.queued_for_write[:original].path rescue "Path didn't exist"
      logger.debug "XML FILE NAME: " + self.xml_file_name.to_s
      logger.debug "=================== /Comprobante.procesar ==================="
      
      begin
        #doc = Nokogiri::XML( File.read(self.xml.queued_for_write[:original].path) )
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
          self.emisor = Emisor.new(file.emisor.instance_values)
          self.receptor = Receptor.new(file.receptor.instance_values)
          
          # Emisor
          logger.debug self.emisor.to_json
          if self.emisor.rfc == self.user.rfc
            self.emitido = true
          else
            if self.receptor.rfc != self.user.rfc
              @notification = Notification.new(
                :description=>"Sent invoice RFC not match",
                :status=>false,
                :email=>self.user.perfil.try(:emailadicional1),
                :invoice_file_name=>self.xml_file_name,
                :validation=>"If Sent(Emitido). Check Emisor RFC",
                :category=>"Error",
                :user_id=>self.user.id
              )
              @notification.save!
            end
          end
          
          # Receptor
          logger.debug self.receptor.to_json
          if self.receptor.rfc == self.user.rfc
            self.recibido = true
          else
            if !self.emitido
              @notification = Notification.new(
                :description=>"Received invoice RFC not match",
                :status=>false,
                :email=>self.user.perfil.try(:emailadicional1),
                :invoice_file_name=>self.xml_file_name,
                :validation=>"If Received(Recibido). Check Receptor RFC",
                :category=>"Error",
                :user_id=>self.user.id
              )
              @notification.save!
            end
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
          @notification = Notification.new(
            :description=>"Version #{@version} No Soportada",
            :status=>false,
            :email=>self.user.perfil.try(:emailadicional1),
            :invoice_file_name=>self.xml_file_name,
            :validation=>"CFDi version not supported",
            :category=>"Error",
            :user_id=>self.user.id
          )
          if @notification.save!
            logger.debug "Version #{@version} No Sportada - notification saved"
          else
            fail "Version #{@version} No Soportada - notification Not saved"
          end
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
  
    def generate_notifications
        c = self
        
        #check if it's already exists
        user_invoices_name = c.user.comprobantes.map(&:xml_file_name)
        dup_invoice = user_invoices_name.select{|i|i==c.xml_file_name}.length rescue 0
        same_notifications = Notification.where(:comprobante_id=>c.id,:description=>"Already exists")
        if dup_invoice>1 && same_notifications.blank?
            Notification.create!(
              :description=>"Already exists",
              :status=>false,
              :email=>c.user.perfil.try(:emailadicional1),
              :invoice_file_name=>c.xml_file_name,
              :validation=>"Already exists",
              :category=>"Warning",
              :comprobante_id=>c.id,
              :user_id=>c.user.id
            )
        end
        
        if c.recibido 
          same_notifications = Notification.where(:comprobante_id=>c.id,:description=>"Received invoice RFC not match")
          if c.receptor.rfc != c.user.rfc && same_notifications.blank?
            Notification.create!(
              :description=>"Received invoice RFC not match",
              :status=>false,
              :email=>c.user.perfil.try(:emailadicional1),
              :invoice_file_name=>c.xml_file_name,
              :validation=>"If the invoice uploaded is a received one, validate Receptor information against company profile",
              :category=>"Warning",
              :comprobante_id=>c.id,
              :user_id=>c.user.id
            )
          end
        end
    
        if c.emitido
          same_notifications = Notification.where(:comprobante_id=>c.id,:description=>"Sent invoice RFC not match")
          if c.emisor.rfc != c.user.rfc && same_notifications.blank?
            Notification.create!(
              :description=>"Sent invoice RFC not match",
              :status=>false,
              :email=>c.user.perfil.try(:emailadicional1),
              :invoice_file_name=>c.xml_file_name,
              :validation=>"If the invoice uploaded is a Sent (Emitido), validate Emisor information against company profile.",
              :category=>"Warning",
              :comprobante_id=>c.id,
              :user_id=>c.user.id
            )
          end
        end 

        file = c.xml_obj rescue nil
        if file.present?
          file_validate_schema = file.validate_schema
          if file_validate_schema!=true and file_validate_schema.kind_of?(Array)
            category = "Error" if file_validate_schema.first.error? and !file_validate_schema.first.warning?
            category = "Warning" if !file_validate_schema.first.error? and file_validate_schema.first.warning?
            same_notifications = Notification.where(:comprobante_id=>c.id,:description=>file_validate_schema.first.to_s)
            if same_notifications.blank?
              Notification.create!(
                :description=>file_validate_schema.first.to_s,
                :status=>false,
                :email=>c.user.perfil.try(:emailadicional1),
                :invoice_file_name=>c.xml_file_name,
                :validation=>"Validate XML against XSLT Schema Files",
                :category=>category,
                :comprobante_id=>c.id,
                :user_id=>c.user.id
              )
            end
          end
        end
       
        #generate success notification and send email"
        other_notifications = Notification.where(:comprobante_id=>c.id)
        if other_notifications.blank?
            Notification.create!(
              :description=>"Success",
              :status=>false,
              :email=>c.user.perfil.try(:emailadicional1),
              :invoice_file_name=>c.xml_file_name,
              :validation=>"Success notification",
              :category=>"Success",
              :comprobante_id=>c.id,
              :user_id=>c.user.id
            )
            #if c.user.perfil.notificarvalidos
            #  UserMailer.success_notification_email(c.user.perfil.emailadicional1,c.xml_file_name).deliver
            #end
        end
  
        
    end
end
