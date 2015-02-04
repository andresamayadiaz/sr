class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def register_payment
    current_user.change_conekta_plan(params[:user])
    redirect_to authenticated_root_url, notice: "Plan is changed to #{current_user.plan.name} with $#{current_user.plan.price} per month"
  end
  
  def perfil
      
    @perfil = current_user.perfil

  end
  
  def update_notificaciones
    
    @perfil = current_user.perfil
    
    if @perfil.update(notificaciones_params)
      flash[:success] = "Notificaciones Actualizadas Exitosamente."
    else
      flash[:alert] = "Error al Actualizar sus Notificaciones, favor de intentar nuevamente."
    end
    
    redirect_to perfil_user_path
    
  end
  
  def update_generales
    @perfil = current_user.perfil
    
    if @perfil.update(generales_params)
      flash[:success] = "Perfil Actualizado Exitosamente."
    else
      flash[:alert] = "Error al Actualizar su Perfil, favor de intentar nuevamente."
    end
    
    redirect_to perfil_user_path
    
  end
  
  def update_password
    
    @user = current_user
    
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:success] = "Password Actualizado Exitosamente."
      redirect_to perfil_user_path
    else
      flash[:alert] = @user.errors.full_messages
      redirect_to perfil_user_path
    end
    
  end
  
  def update_logo
    
    @user = current_user
    
    @user.logo = params[:file]
    @user.save
    
    render :json => @user.logo.url(:medium)
    
  end
  
  private
  
    def user_params
      # NOTE: Using `strong_parameters` gem
      params.required(:user).permit(:password, :password_confirmation, :current_password)
    end
    
    def generales_params
      params.required(:perfil).permit(:calle, :noexterior, :nointerior, :colonia, :ciudad, :estado, :cp, :user_attributes => [:name, :id])
    end
    
    def notificaciones_params
      params.required(:perfil).permit(:notificarfaltas, :notificaradvertencias, :notificarvalidos, :emailadicional1, :emailadicional2)
    end

end
