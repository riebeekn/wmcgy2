module ReportsHelper
  def chart_tag (action, height, width, params = {})
    params[:format] ||= :json
    path = reports_path(action, params)
    content_tag(:div, :'data-chart' => path, :style => "height: #{height}px;width: #{width}") do
      image_tag('spinner.gif', :size => '24x24', :class => 'spinner')
    end
  end
end
