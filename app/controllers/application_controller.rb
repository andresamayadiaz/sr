class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_notifications

  private
    def set_notifications
      if user_signed_in?
        all_alertas = current_user.notifications
        all_unread_alertas = all_alertas.select{|a|a.status==false}
        all_advertencias = all_alertas.select{|a|a.category=='Warning'}
        all_faltas = all_alertas.select{|a|a.category=='Error'}
        all_validos = all_alertas.select{|a|a.category=='Success'}
        all_actual = all_alertas.select{|a|a.created_at.month==Time.now.month}
        all_anterior = all_alertas.select{|a|a.created_at.month==(Time.now-1.month).month}
        all_leidos = all_alertas.select{|a|a.status==true}
      
        @unreads_count = all_unread_alertas.length
        @advertencias_count = all_advertencias.length
        @faltas_count = all_faltas.length
        @validos_count = all_validos.length
        @actual_count = all_actual.length
        @anterior_count = all_anterior.length
        @leidos_count = all_leidos.length
      
        if params[:filter].present?
          case params[:filter]
          when 'advertencias'
            @alertas = all_advertencias
          when 'faltas'
            @alertas = all_faltas
          when 'validos'
            @alertas = all_validos
          when 'mes-actual'
            @alertas = all_actual
          when 'mes-anterior'
            @alertas = all_anterior
          when 'leidos'
            @alertas = all_leidos
          end
        else
          @alertas = all_unread_alertas
        end
        @alertas = @alertas.sort_by{|a|a.created_at}.reverse! rescue []
        @ten_most_recent_alertas = all_unread_alertas.first(10)
      end
    end
end
