module ApplicationHelper
  def active(controller, action = nil)
    ' class="active"'.html_safe if controller.to_sym == controller_name.to_sym && (!action || action.to_sym == action_name.to_sym)
  end
end
