# aad mayo 2014

class HomeController < ApplicationController
  
  def index
    
    @user = User.find(current_user.id)
    
    
    
  end
  
  def update_comprobante
    
    @user = User.find(current_user.id)
    
    logger.debug "Entro a update_comprobante"
    
    
    
  end
  
end
