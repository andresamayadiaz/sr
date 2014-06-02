# aad mayo 2014

class HomeController < ApplicationController
  
  def index
    
    @user = User.find(current_user.id)
    @perfil = @user.perfil
    
  end
  
  def emitidos
    
    @user = User.find(current_user.id)
    
    @emitidos = @user.comprobantes.where("emitido = ?", true)
    
  end
  
  def recibidos
    
    @user = User.find(current_user.id)
    
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
  
end
