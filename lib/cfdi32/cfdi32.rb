# aad mayo 2014
require 'comprobantefactory'
require 'libxslt'

module COMPROBANTEFACTORY
  
  # Clase Cfdi32 para comprobnates CFDI version 3.2
  #
  class Cfdi32 < COMPROBANTEFACTORY::Comprobante
    
    attr_accessor :doc
    
    def initialize(doc)
      
      @doc = doc
      
      #TODO if version !- 3.2 raise error
      
      # Atributos Requeridos
      @version = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("version").to_s
      @fecha = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("fecha").to_s
      @sello = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("sello").to_s
      @certificado = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("certificado").to_s
      @tipoDeComprobante = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("tipoDeComprobante").to_s
      @formaDePago = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("formaDePago").to_s
      @noCertificado = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("noCertificado").to_s
      @subTotal = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("subTotal").to_s.to_d
      @total = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("total").to_s.to_d
      @metodoDePago = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("metodoDePago").to_s
      @lugarExpedicion = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("lugarExpedicion").to_s
      @serie = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("serie").to_s
      @folio = @doc.root.xpath("//cfdi:Comprobante", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("folio").to_s
      
      # Emisor
      @emisor = COMPROBANTEFACTORY::Emisor.new
      #@emisor.rfc = @doc.root.xpath("//cfdi:Comprobante/Emisor").attribute("rfc").to_s
      @emisor.rfc = @doc.root.xpath("//cfdi:Emisor", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("rfc").to_s
      @emisor.regimenFiscal = @doc.root.xpath("//cfdi:Emisor", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("regimenFiscal").to_s
      @emisor.nombre = @doc.root.xpath("//cfdi:Emisor", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("nombre").to_s
      #logger.debug "Emisor: #{@emisor.to_json.to_s}"
      
      # Receptor
      @receptor = COMPROBANTEFACTORY::Receptor.new
      #@receptor.rfc = @doc.root.xpath("//cfdi:Comprobante/Receptor").attribute("rfc").to_s
      @receptor.rfc = @doc.root.xpath("//cfdi:Receptor", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("rfc").to_s
      @receptor.nombre = @doc.root.xpath("//cfdi:Receptor", 'cfdi' => @doc.collect_namespaces["xmlns:cfdi"]).attribute("nombre").to_s
      #logger.debug "Receptor: #{@receptor.to_json.to_s}"
      
      # Otros
      @timbre = COMPROBANTEFACTORY::TimbreFiscal.new
      @uuid = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("UUID").to_s
      @timbre.uuid = @uuid
      
      @selloSAT = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("selloSAT").to_s
      @timbre.selloSAT = @selloSAT
      
      @selloCFD = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("selloCFD").to_s
      @timbre.selloCFD = @selloCFD
      
      @versionComplemento = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("version").to_s
      @timbre.version = @versionComplemento
      
      @noCertificadoSAT = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("noCertificadoSAT").to_s
      @timbre.noCertificadoSAT = @noCertificadoSAT
      
      @fechaTimbrado = @doc.root.xpath("//tfd:TimbreFiscalDigital", 'tfd' => @doc.collect_namespaces["xmlns:tfd"]).attribute("FechaTimbrado").to_s
      @timbre.fechaTimbrado = @fechaTimbrado
      
    end
    
    def cadena_original
  
      stylesheet_doc = LibXML::XML::Document.file("public/sat/cadenaoriginal_3_2.xslt")
      stylesheet = LibXSLT::XSLT::Stylesheet.new(stylesheet_doc)
  
      result = stylesheet.apply(@doc)
  
      result.child.to_s
  
    end
    
    def uuid
      @uuid
    end
    
  end
  
end