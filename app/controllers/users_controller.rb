class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def perfil
      @user = User.find(current_user.id)
      
      if params[:user_params]
        if @user.update_with_password(user_params)
          logger.log "entro if"
          # Sign in the user by passing validation in case his password changed
          sign_in @user, :bypass => true
          redirect_to users_perfil_path
        else
          logger.log "entro else"
          flash[:alert] = "Some errors occured"
          render "perfil"
        end
      end
    end

end
