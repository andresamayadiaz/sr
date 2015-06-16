class Notification < ActiveRecord::Base
  
  belongs_to :comprobante
  belongs_to :user
  
  scope :warnings, -> { where(category: 'Warning') }
  scope :errors, -> { where(category: 'Error') }
  scope :success, -> { where(category: 'Success') }
  
  after_create :send_email
  
  private
  
    # Enviar Email si tiene habilitada la opcion en el perfil
    def send_email
    
      if self.category == "Success"
        
        UserMailer.success_notification_email(c.user.perfil.emailadicional1,c.xml_file_name).deliver
        
      elsif self.category == "Warning"
        
        UserMailer.warning_notification_email(c.user.perfil.emailadicional1,c.xml_file_name).deliver
        
      elsif self.category == "Error"
        
        UserMailer.error_notification_email(c.user.perfil.emailadicional1,c.xml_file_name).deliver
        
      end
    
    end
  
end
