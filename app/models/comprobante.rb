class Comprobante < ActiveRecord::Base
  
  belongs_to :emisor
  belongs_to :receptor
  
  has_attached_file :xml,
  :path => ":rails_root/public/system/:class/:attachment/:id_partition/:filename"
  
  before_save :procesar
  
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
    
    def comprobante
      
      # regresar el objeto COMPROBANTE::Comprobante de este comprobante
      
    end
    
  private
    def procesar
      
      # Abrir XML, pre validaciones, guarda su emisor, receptor, etc ...
      doc = Nokogiri::XML( File.read(self.xml.path) )
      @version = doc.root.xpath("//cfdi:Comprobante").attribute("version").to_s
      
      if @version == '3.2'
        
        attr = COMPROBANTEFACTORY::Cfdi32.new(self.xml.path)
        self.version = attr.version
        self.fecha = attr.fecha
        self.sello = attr.sello
        
        logger.debug attr.to_json
        
      else
        # version no soportada o nula
        logger.debug "Version No Soportada"
      end
      
    end
  
end