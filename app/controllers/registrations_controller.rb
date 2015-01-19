class RegistrationsController < Devise::RegistrationsController
  before_filter :update_sanitized_params, if: :devise_controller?

  before_filter :check_plan

  def check_plan
    if params[:plan].present?
      @plan = Plan.find(params[:plan]) 
    end
  end

  
  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation, :rfc, :conektaTokenId, :plan_id)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password,:conektaTokenId, :plan_id)}
  end
end
