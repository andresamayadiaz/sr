# aad mayo 2014 - inicial
# aad julio 2014 - tags, lista con filtros de emitidos y recibidos, paginado

class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_comprobante, only: [:comprobante, :add_tag, :remove_tag, :cbb, :eliminar, :download_xml, :download_pdf]
  before_filter :set_vars, only: [:emitidos, :recibidos, :otros, :alertas, :view_single_notification, :buscar_de_alertas, :upgrade, :downgrade]
  before_filter :set_sort

  def download_xml
    send_file @comprobante.xml.path,
            :type => 'text/xml; charset=UTF-8;' 
  end

  def download_pdf
    @user = current_user
    @warnings = @comprobante.notifications.warnings
    @errors = @comprobante.notifications.errors
    pdf = render_to_string :pdf => "PDF_SoyReceptor", :template => "home/download_pdf.html.erb", :encoding => "UTF-8", :layout=>'pdf'
    send_data pdf
  end
 
  def index
    
    @user = current_user
    @perfil = @user.perfil
    @top_10_clients = Comprobante.top_10_clients(current_user.id)
    @top_10_suppliers = Comprobante.top_10_suppliers(current_user.id)
    @sent_invoices = Comprobante.sent_invoices(current_user.id)
    @rec_invoices = Comprobante.received_invoices(current_user.id)
    @sent_amount = Comprobante.sent_amount(current_user.id)
    @rec_amount = Comprobante.received_amount(current_user.id)
  end
  
  def comprobante
    
    @user = current_user
    @warnings = @comprobante.notifications.warnings
    @errors = @comprobante.notifications.errors
    render layout: "comprobante"
    
  end

  def eliminar
    if @comprobante.destroy
      redirect_to authenticated_root_url, notice: "Invoice and all of its related info have been deleted"
    else
      redirect_to authenticated_root_url, error: "Failed to delete invoice"
    end
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
    if current_user.comprobantes.count<current_user.plan.max_uploaded
      @user = current_user
      @comprobante = Comprobante.new
      @comprobante.xml = params[:file]
      @comprobante.user = @user
      
      begin
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
      rescue => e
          render :json=> {:error => e.message}.to_json, :status => 406
      end
    else
      render :json => {:error => "Upload failed! You have exceeded your plan limit. Consider to <a href='/upgrade' style='text-decoration: underline;font-weight:bold;'>upgrade</a> your plan".html_safe}.to_json, :status => 422
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

  def upgrade
    @plans = Plan.where('price>?',current_user.plan.price) rescue nil
    render 'plans_list'
  end

  def downgrade
    @plans = Plan.where('price<?',current_user.plan.price) rescue nil
    render 'plans_list'
  end

  def new_payment
    @user = current_user
    @new_plan = Plan.find(params[:plan_id])
    if @new_plan.price==0
      current_user.update_attribute('plan_id',params[:plan_id])
      redirect_to authenticated_root_url, notice: "You are now on Free plan"
    else
      if current_user.customer_id.blank?
        render 'new_payment'
      else
        current_user.change_conekta_plan(params)
        redirect_to authenticated_root_url, notice: "Plan is changed to #{@new_plan.name} with $#{@new_plan.price} per month"
      end
    end
  end

 
  private
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
