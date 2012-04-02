# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)
#  password_digest        :string(255)
#  auth_token             :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  activation_token       :string(255)
#  activation_sent_at     :datetime
#  active                 :boolean
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation
  attr_accessor   :should_validate_password
  
  has_secure_password
  
  has_many :categories, dependent: :destroy
  has_many :transactions, dependent: :destroy
  
  valid_email_regex =  Email.EMAIL_REGEX 
  validates :email, presence: true, format: { with: valid_email_regex },
                    uniqueness: { case_sensitive: false }, length: { maximum: 254 }
  validates :password, length: { within: 6..40 }, on: :create
  validates :password, length: { within: 6..40 }, if: :should_validate_password
  
  before_create { generate_token(:auth_token) }
  
  def send_activation_email
    generate_token(:activation_token)
    self.activation_sent_at = Time.zone.now
    save!
    UserMailer.activation(self).deliver
  end
  
  def send_password_reset_email
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end
  
  def activate
    self.active = true
    save!
  end
  
  private
  
    def generate_token(column)
      begin 
        self[column] =  SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end

