# aad mayo 2014 - inicial
# aad julio 2014 - tags, lista con filtros de emitidos y recibidos, paginado

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_comprobante, only: [:comprobante, :add_tag, :remove_tag, :cbb]
  
  def index
    
    @user = User.find(current_user.id)
    @perfil = @user.perfil
    
  end
  
  def comprobante
    
    @user = User.find(current_user.id)
    
    render layout: "comprobante"
    
  end
  
  def cbb
    
    txt = @comprobante.xml_obj.timbre.cadena_original
    
    respond_to do |format|
      format.png  { render :qrcode => txt, :size => 10, :level => :l, :unit => 10 }
    end
    
  end
  
  def tags
    
    @user = User.find(current_user.id)
    
    logger.debug "TAGS: "
    logger.debug params[:tags]
    
    if params[:tags].blank?
      @tags = []
    else
      @tags = params[:tags].split ","
    end
    
    @comprobantes = Comprobante.tagged_with(@tags, :wild => true).page params[:page]
    # :match_all => true, 
    # Find users that matches all given tags:
    #User.tagged_with(["awesome", "cool"], :match_all => true)
    
    # Find users with any of the specified tags:
    #User.tagged_with(["awesome", "cool"], :any => true)
    
  end
  
  def emitidos
    
    @user = User.find(current_user.id)
    
    if params[:from] and params[:to]
      @from = params[:from]
      @to = params[:to]
    else
      @from = Date.today.at_beginning_of_month.to_s
      @to = Date.today.at_end_of_month.to_s
    end
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @emitidos = @user.comprobantes.joins(:receptor).where("emitido = ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", true, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q).page params[:page]
    
  end
  
  def recibidos
    
    @user = User.find(current_user.id)
    
    if params[:from] and params[:to]
      @from = params[:from]
      @to = params[:to]
    else
      @from = Date.today.at_beginning_of_month.to_s
      @to = Date.today.at_end_of_month.to_s
    end
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @recibidos = @user.comprobantes.joins(:emisor).where("recibido = ? AND fecha BETWEEN ? AND ? AND (emisors.rfc LIKE ? OR emisors.nombre LIKE ?)", true, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q).page params[:page]
    
  end
  
  def otros
    
    @user = User.find(current_user.id)
    
    if params[:from] and params[:to]
      @from = params[:from]
      @to = params[:to]
    else
      @from = Date.today.at_beginning_of_month.to_s
      @to = Date.today.at_end_of_month.to_s
    end
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @otros = @user.comprobantes.joins(:receptor).where("emitido = ? AND recibido= ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", false, false, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q).page params[:page]  
    
  end
  
  def add_tag
    
    @added_tag = params[:tag]
    
    @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@added_tag), :on => :tags)
    
    if @comprobante.save
      render :json => @comprobante.tag_list.to_json
    else
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
    end
    
  end
  
  def remove_tag
    
    @removed_tag = params[:tag]
    
    @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).remove(@removed_tag), :on => :tags)
    
    if @comprobante.save
      render :json => @comprobante.tag_list.to_json
    else
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
    end
    
  end
  
  def upload_comprobante
    
    @user = User.find(current_user.id)
    
    @comprobante = Comprobante.new
    @comprobante.xml = params[:file]
    @comprobante.user = @user
    
    if @comprobante.save
      
      # Save Default Tags
      @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@comprobante.tipoDeComprobante), :on => :tags)
      if !@comprobante.xml_obj.moneda.blank?
        @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@comprobante.xml_obj.moneda), :on => :tags)
      end
      
      render :json => @comprobante.xml.url
      
    else
      
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
      
    end
  
  end

  def buscar
        
    @user = current_user
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @buscar = @user.comprobantes.joins(:receptor,:emisor,:TimbreFiscalDigital).where("serie LIKE ? OR folio LIKE? OR receptors.rfc LIKE ? OR receptors.nombre LIKE ? OR emisors.rfc LIKE ? OR emisors.nombre LIKE ? OR timbre_fiscal_digitals.uuid LIKE ?", @q, @q, @q, @q, @q, @q, @q).page params[:page]

  end
  
  private
    
    # Use callbacks to share common setup or constraints between actions.
    def set_comprobante
      @comprobante = current_user.comprobantes.find(params[:id])
    end
  
end
