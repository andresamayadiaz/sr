# aad mayo 2014

class HomeController < ApplicationController
  
  def index
    
    @user = User.find(current_user.id)
    @perfil = @user.perfil
    
  end
  
  def upload_comprobante
    
    @user = User.find(current_user.id)
    
    logger.debug "Entro a upload_comprobante"
    
    
    
    
  end
  
end
