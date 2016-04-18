class User < ActiveRecord::Base
  enum role: [:user, :admin]
  has_many :jobs, dependent: :destroy

  before_destroy :fix_stats_table_user
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

  def fix_stats_table_user
    Stat.where(user_id: self.id).update_all(user_id: nil)
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end
end
