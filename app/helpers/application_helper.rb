module ApplicationHelper

  
  def flash_class(level)
    case level
      when 'notice' then "alert-info"
      when 'success' then "alert-success"
      when 'error' then "alert-danger"
      when 'alert' then "alert-danger"
    end
  end
  
  def base64_image image_data
    "<img src='data:image/png;base64,#{image_data}' />".html_safe
  end
  
  def is_active
  end

end
