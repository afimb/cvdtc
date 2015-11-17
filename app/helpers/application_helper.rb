module ApplicationHelper
  def is_active(controller)
    ' class="active"'.html_safe if controller.to_sym == controller_name.to_sym
  end
end
