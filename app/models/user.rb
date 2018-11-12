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

  has_many :categories, dependent: :destroy, order: :name
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

  def expenses_by_month_for_current_year(year = Time.now.year)
    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date_trunc('year', date) = to_timestamp('#{year}', 'YYYY') AND is_debit = true").
      group(1).
      order(1)
  end

  def expenses_for_last_12_months
    period_start = Time.now - 11.months
    start_date = "#{period_start.year}-#{period_start.month}-01 00:00:00"
    end_date = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day} 23:59:59"

    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date BETWEEN '#{start_date}' AND '#{end_date}' AND is_debit = true").
      group(1).
      order(1)
  end

  # methods for trend charts... NOTE, could use some refactoring, combine income / expense_categories
  # methods as only difference is the is_debit clause
  def expense_categories
    names = transactions.
      select("distinct name").
      joins("inner join categories on transactions.category_id = categories.id").
      where("is_debit = true").
      order(1)

    names.map{|c| c.name}
  end

  def income_categories
    names = transactions.
      select("distinct name").
      joins("inner join categories on transactions.category_id = categories.id").
      where("is_debit = false").
      order(1)

    names.map{|c| c.name}
  end

  def expenses_by_category_and_month_for_current_year(year = Time.now.year)
    transactions.
      select("extract(month from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("date_trunc('year', date) = to_timestamp('#{year}', 'YYYY') AND is_debit = true").
      group(1, 2).
      order(1, 2)
  end

  def income_by_category_and_month_for_current_year(year = Time.now.year)
    transactions.
      select("extract(month from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("date_trunc('year', date) = to_timestamp('#{year}', 'YYYY') AND is_debit = false").
      group(1, 2).
      order(1, 2)
  end

  def expenses_by_category_and_year
    transactions.
      select("extract(year from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("is_debit = true AND extract(year from date) != extract(year from current_date)").
      group(1, 2).
      order(1, 2)
  end

  def income_by_category_and_year
    transactions.
      select("extract(year from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("is_debit = false").
      group(1, 2).
      order(1, 2)
  end

  def expenses_by_category_for_last_12_months
    period_start = Time.now - 12.months
    period_end = Time.now.beginning_of_month - 1.day
    start_date = "#{period_start.year}-#{period_start.month}-01 00:00:00"
    end_date = "#{period_end.year}-#{period_end.month}-#{period_end.day} 23:59:59"

    transactions.
      select("extract(month from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("date BETWEEN '#{start_date}' AND '#{end_date}' AND is_debit = true").
      group(1, 2).
      order(1, 2)
  end

  def income_by_category_for_last_12_months
    period_start = Time.now - 12.months
    period_end = Time.now.beginning_of_month - 1.day
    start_date = "#{period_start.year}-#{period_start.month}-01 00:00:00"
    end_date = "#{period_end.year}-#{period_end.month}-#{period_end.day} 23:59:59"

    transactions.
      select("extract(month from date) as period, name, sum(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where("date BETWEEN '#{start_date}' AND '#{end_date}' AND is_debit = false").
      group(1, 2).
      order(1, 2)
  end
  # end methods for trend charts

  def income_by_category_and_date_range(range)
    transactions.
      select("name, SUM(amount)").
      joins("LEFT JOIN categories on categories.id = transactions.category_id").
      where(where_clause_for_transactions_by_date_and_category(false, range)).
      group("name").
      order("name")
  end

  def income_for_last_12_months
    period_start = Time.now - 11.months
    start_date = "#{period_start.year}-#{period_start.month}-01 00:00:00"
    end_date = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day} 23:59:59"

    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date BETWEEN '#{start_date}' AND '#{end_date}' AND is_debit = false").
      group(1).
      order(1)
  end

  def income_by_year
    transactions.
      select("extract(year from date) as period, sum(amount)").
      where("is_debit = false").
      group(1).
      order(1)
  end

  def income_by_month_for_current_year(year = Time.now.year)
    transactions.
      select("extract(month from date) as period, sum(amount)").
      where("date_trunc('year', date) = to_timestamp('#{year}', 'YYYY') AND is_debit = false").
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
        # note this isn't ideal, see project template where we don't create
        # a valid password digest for oauth users, in theory with the below
        # some one could log in via the custom authentication by
        # guessing the random password... this is likely close to impossible
        # but would be better to disallow custom authentication when user
        # is created via oauth
        pwd = SecureRandom.urlsafe_base64
        user.password = pwd
        user.password_confirmation = pwd

        user.active = true
      end
    end
end
