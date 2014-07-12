# aad mayo 2014

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_comprobante, only: [:comprobante]
  
  def index
    
    @user = User.find(current_user.id)
    @perfil = @user.perfil
    
  end
  
  def comprobante
    
    @user = User.find(current_user.id)
    
    
    
  end
  
  def emitidos
    
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
    
    @emitidos = @user.comprobantes.joins(:receptor).where("emitido = ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", true, @from, @to, @q, @q).page params[:page]
    
    cookies[:current_page] = params[:page]
    
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
    
    cookies[:current_page] = params[:page]
    
  end
  
  def upload_comprobante
    
    @user = User.find(current_user.id)
    
    logger.debug "HomeController.upload_comprobante"
    
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
