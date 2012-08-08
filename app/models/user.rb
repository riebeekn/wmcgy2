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
#  name                   :string(255)
#  provider               :string(255)
#  uid                    :string(255)
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
  validates :password_confirmation, presence: true, if: :should_validate_password
  
  before_create { generate_token(:auth_token) }
  before_create { set_name_if_empty }
  before_save { |user| user.email = user.email.downcase }
  
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
  
  def self.from_omniauth(auth)
    User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
  end
  
  def mtd
    credit = transactions.
      select("SUM(amount)").
      where("date_trunc('month', date) = date_trunc('month', now()) AND is_debit = true").
      first.sum
    debit = transactions.
      select("SUM(amount)").
      where("date_trunc('month', date) = date_trunc('month', now()) AND is_debit = false").
      first.sum
    credit.to_f + debit.to_f
  end
  
  def ytd
    credit = transactions.
      select("SUM(amount)").
      where("date_trunc('year', date) = date_trunc('year', now()) AND is_debit = true").
      first.sum
    debit = transactions.
      select("SUM(amount)").
      where("date_trunc('year', date) = date_trunc('year', now()) AND is_debit = false").
      first.sum
    credit.to_f + debit.to_f
  end
  
  def expenses_by_category_and_date_range(range)
    transactions.
      select("name, SUM(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where(where_clause_for_transactions_by_date_and_category(true, range)).
      group("name").
      order("name")
  end
  
  def expenses_by_year
    transactions.
      select("extract(year from date) as period, sum(amount)").
      where("is_debit = true").
      group(1).
      order(1)
  end
  
  def expenses_by_month_for_current_year
    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date_trunc('year', date) = date_trunc('year', now()) AND is_debit = true").
      group(1).
      order(1)
  end
  
  def income_by_category_and_date_range(range)
    transactions.
      select("name, SUM(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where(where_clause_for_transactions_by_date_and_category(false, range)).
      group("name")
  end
  
  def income_by_year
    transactions.
      select("extract(year from date) as period, sum(amount)").
      where("is_debit = false").
      group(1).
      order(1)
  end
  
  def income_by_month_for_current_year
    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date_trunc('year', date) = date_trunc('year', now()) AND is_debit = false").
      group(1).
      order(1)
  end
  
  private
  
    def generate_token(column)
      begin 
        self[column] =  SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
    
    def set_name_if_empty
      if name.nil?
        self.name = email
      end
    end
    
    def where_clause_for_transactions_by_date_and_category(is_debit, range)
      where_clause = is_debit == true ? "is_debit=true" : "is_debit=false" 
      if !range.nil?
        if range.include? ':TO:'
          date_vals = range.split(':TO:')
          date_vals[0] += ' 00:00:00'
          date_vals[1] += ' 23:59:59'
          where_clause += " AND date BETWEEN '#{date_vals[0]}' AND '#{date_vals[1]}'"
        end
      end
      
      where_clause
    end
    
    def self.create_with_omniauth(auth)
      User.create do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.name = auth["info"]["name"]
        if user.provider == 'twitter'
          # twitter does not provide the user's email
          user.email = "#{user.uid}.no.email.for.twitter@example.com"
        else
          user.email = auth["info"]["email"]
        end
        user.password = 'nopasswordneeded'
        user.password_confirmation = 'nopasswordneeded'
        user.active = true
      end
    end
end
