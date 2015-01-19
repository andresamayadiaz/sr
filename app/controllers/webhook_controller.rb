class WebhookController < ApplicationController
  
  skip_before_filter :verify_authenticity_token #to allow conekta API send post request
  
  def conekta
    #to add more logic here
    head :ok, content_type: "text/html"
  end
end
