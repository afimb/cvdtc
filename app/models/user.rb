class User < ActiveRecord::Base
  enum role: [:user, :admin]
  after_initialize :set_default_role, if: :new_record?

  before_save :ensure_authentication_token

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def renew_token
    self.authentication_token = nil
    self.save
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end
end
