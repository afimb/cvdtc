module ApplicationHelper
  def active(current_menu, menu)
    ' class="active"'.html_safe if current_menu == menu
  end

  def active_controller(controller)
    ' class="active"'.html_safe if controller.to_sym == controller_name.to_sym
  end
end
