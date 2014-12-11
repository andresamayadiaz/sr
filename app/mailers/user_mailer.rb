class UserMailer < ActionMailer::Base
  default from: "no-reply@soyreceptor.com"
  
  def success_notification_email(email,xml_file_name)
    @email = email
    @xml_file_name = xml_file_name
    mail(to: @email, subject: "Success Notification: #{@xml_file_name}")
  end

end
