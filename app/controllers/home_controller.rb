# aad mayo 2014 - inicial
# aad julio 2014 - tags, lista con filtros de emitidos y recibidos, paginado

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_comprobante, only: [:comprobante, :add_tag, :remove_tag]
  
  def index
    
    @user = User.find(current_user.id)
    @perfil = @user.perfil
    
  end
  
  def comprobante
    
    @user = User.find(current_user.id)
    
    render layout: "comprobante"
    
  end
  
  def emitidos
    
    @user = User.find(current_user.id)
    logger.debug "USER TAG CLOUD: " + @user.tag_cloud.to_json
    
    if params[:from] and params[:to]
      @from = params[:from]
      @to = params[:to]
    else
      @from = Date.today.at_beginning_of_month
      @to = Date.today.at_end_of_month
    end
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @emitidos = @user.comprobantes.joins(:receptor).where("emitido = ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", true, @from, @to, @q, @q).page params[:page]
    
  end
  
  def recibidos
    
    @user = User.find(current_user.id)
    
    if params[:from] and params[:to]
      @from = params[:from]
      @to = params[:to]
    else
      @from = Date.today.at_beginning_of_month
      @to = Date.today.at_end_of_month
    end
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @recibidos = @user.comprobantes.joins(:emisor).where("recibido = ? AND fecha BETWEEN ? AND ? AND (emisors.rfc LIKE ? OR emisors.nombre LIKE ?)", true, @from, @to, @q, @q).page params[:page]
    
  end
  
  def add_tag
    
    @added_tag = params[:tag]
    
    @comprobante.tag_list.add(@added_tag)
    
    if @comprobante.save
      render :json => @comprobante.tag_list.to_json
    else
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
    end
    
  end
  
  def remove_tag
    
    @removed_tag = params[:tag]
    
    @comprobante.tag_list.remove(@removed_tag)
    
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
      
      render :json => @comprobante.xml.url
      
    else
      
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
      
    end

  end
  
  private
    
    # Use callbacks to share common setup or constraints between actions.
    def set_comprobante
      @comprobante = current_user.comprobantes.find(params[:id])
    end
  
end
