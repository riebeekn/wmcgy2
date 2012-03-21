module ApplicationHelper
  
  def logo
    image_tag("logo.png", alt: "Where'd my cash go?")
  end
  
  # Returns the full title on per-page basis.
  def full_title(page_title)
    base_title = I18n.t(:app_base_title)
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
