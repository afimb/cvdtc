class Users::RegistrationsController < Devise::RegistrationsController
  def renew_token
    current_user.renew_token
    redirect_to :back
  end
end
