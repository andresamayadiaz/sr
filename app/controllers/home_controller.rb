# aad mayo 2014 - inicial
# aad julio 2014 - tags, lista con filtros de emitidos y recibidos, paginado

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_comprobante, only: [:comprobante, :add_tag, :remove_tag, :cbb]
  before_filter :set_notifications
  before_filter :set_vars, only: [:emitidos, :recibidos, :otros, :alertas, :view_single_notification, :buscar_de_alertas]
  before_filter :set_sort
 
  def index
    
    @user = current_user
    @perfil = @user.perfil
    @top_10_clients = Comprobante.top_10_clients
    @top_10_suppliers = Comprobante.top_10_suppliers
    @sent_invoices = Comprobante.sent_invoices
    @rec_invoices = Comprobante.received_invoices
  end
  
  def comprobante
    
    @user = current_user
    @warnings = @comprobante.notifications.warnings
    @errors = @comprobante.notifications.errors
    render layout: "comprobante"
    
  end
  
  def cbb
    
    txt = @comprobante.xml_obj.timbre.cadena_original
    
    respond_to do |format|
      format.png  { render :qrcode => txt, :size => 10, :level => :l, :unit => 10 }
    end
    
  end
  
  def tags
    
    @user = current_user
    
    logger.debug "TAGS: "
    logger.debug params[:tags]
    
    if params[:tags].blank?
      @tags = []
    else
      @tags = params[:tags].split ","
    end
    
    @comprobantes = Comprobante.tagged_with(@tags, :wild => true)
    @comprobantes = Sorter.sort_by_fecha(@sort,@comprobantes)
    @comprobantes = Kaminari.paginate_array(@comprobantes).page params[:page]
    # :match_all => true, 
    # Find users that matches all given tags:
    #User.tagged_with(["awesome", "cool"], :match_all => true)
    
    # Find users with any of the specified tags:
    #User.tagged_with(["awesome", "cool"], :any => true)
    
  end
  
  def emitidos
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @emitidos = @user.comprobantes.joins(:receptor).where("emitido = ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", true, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q)
    @emitidos = Sorter.sort_by_fecha(@sort,@emitidos)
    @emitidos = Kaminari.paginate_array(@emitidos).page params[:page]
  end
  
  def recibidos
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @recibidos = @user.comprobantes.joins(:emisor).where("recibido = ? AND fecha BETWEEN ? AND ? AND (emisors.rfc LIKE ? OR emisors.nombre LIKE ?)", true, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q)
    @recibidos = Sorter.sort_by_fecha(@sort,@recibidos)
    @recibidos = Kaminari.paginate_array(@recibidos).page params[:page]
  end
  
  def otros
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @otros = @user.comprobantes.joins(:receptor).where("emitido = ? AND recibido= ? AND fecha BETWEEN ? AND ? AND (receptors.rfc LIKE ? OR receptors.nombre LIKE ?)", false, false, @from + ' 00:00:00', @to + ' 23:59:59', @q, @q) 
    @otros = Sorter.sort_by_fecha(@sort,@otros)
    @otros = Kaminari.paginate_array(@otros).page params[:page]
  end
  
  def add_tag
    
    @added_tag = params[:tag]
    
    @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@added_tag), :on => :tags)
    
    if @comprobante.save
      render :json => @comprobante.tag_list.to_json
    else
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
    end
    
  end
  
  def remove_tag
    
    @removed_tag = params[:tag]
    
    @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).remove(@removed_tag), :on => :tags)
    
    if @comprobante.save
      render :json => @comprobante.tag_list.to_json
    else
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
    end
    
  end
  
  def upload_comprobante
    
    @user = current_user
    
    @comprobante = Comprobante.new
    @comprobante.xml = params[:file]
    @comprobante.user = @user
    
    if @comprobante.save
      
      # Save Default Tags
      @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@comprobante.tipoDeComprobante), :on => :tags)
      if !@comprobante.xml_obj.moneda.blank?
        @comprobante.user.tag(@comprobante, :with => @comprobante.tags_from(@comprobante.user).add(@comprobante.xml_obj.moneda), :on => :tags)
      end
      
      render :json => @comprobante.xml.url
      
    else
      
      render :json => {:error => "Not Acceptable"}.to_json, :status => 406
      
    end
  
  end

  def buscar
        
    @user = current_user
    
    if params[:q]
      @q = '%' + params[:q] + '%'
    else
      @q = '%%'
    end
    
    @buscar = @user.comprobantes.joins(:receptor,:emisor,:TimbreFiscalDigital).where("serie LIKE ? OR folio LIKE? OR receptors.rfc LIKE ? OR receptors.nombre LIKE ? OR emisors.rfc LIKE ? OR emisors.nombre LIKE ? OR timbre_fiscal_digitals.uuid LIKE ?", @q, @q, @q, @q, @q, @q, @q)
    @buscar = Sorter.sort_by_fecha(@sort,@buscar)
    @buscar = Kaminari.paginate_array(@buscar).page params[:page]
  end

  def alertas
    @alertas = Kaminari.paginate_array(@alertas).page(params[:page])
  end

  def view_single_notification
    @notification = Notification.find(params[:id])
    if @notification.present?
      @notification.update_attributes!(:status=>true)
    end
  end
  
  def buscar_de_alertas
    if params[:qa].present?
      qa = params[:qa]
      @alertas = @alertas.select{|a|
        a.comprobante.to_s.include? qa or
        a.comprobante.total.to_s.include? qa or
        a.comprobante.fecha.to_s.include? qa or
        a.comprobante.tipoDeComprobante.include? qa or
        a.comprobante.emisor.rfc.include? qa or
        a.comprobante.emisor.nombre.include? qa or
        a.comprobante.receptor.rfc.include? qa or
        a.comprobante.receptor.nombre.include? qa
      }
    end
     @alertas = Kaminari.paginate_array(@alertas).page(params[:page])
    render 'alertas'
  end 
 
  private
    def set_notifications

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

    def set_vars
      
      @user = current_user
    
      if params[:from] and params[:to]
        @from = params[:from]
        @to = params[:to]
      else
        @from = Date.today.at_beginning_of_month.to_s
        @to = Date.today.at_end_of_month.to_s
      end

    end
    
    def set_sort
      @sort = params[:sort].upcase if params[:sort].present?
    end 
    
    # Use callbacks to share common setup or constraints between actions.
    def set_comprobante
      @comprobante = current_user.comprobantes.find(params[:id])
    end
  
end
