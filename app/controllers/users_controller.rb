class UsersController < ApplicationController
  before_filter :authenticate_user!

  def perfil
      
    @user = User.find(current_user.id)

  end
  
  def update_notificaciones
    
  end
  
  def update_generales
    
  end
  
  def update_password
    
    @user = User.find(current_user.id)
    
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:success] = "Password Actualizado Exitosamente"
      redirect_to perfil_user_path
    else
      flash[:alert] = @user.errors.full_messages
      redirect_to perfil_user_path
    end
    
  end
  
  private
  
    def user_params
      # NOTE: Using `strong_parameters` gem
      params.required(:user).permit(:password, :password_confirmation, :current_password)
    end

end
