# == Schema Information
#
# Table name: transactions
#
#  id          :integer         not null, primary key
#  description :string(255)
#  date        :datetime
#  amount      :decimal(10, 2)  default(0.0)
#  is_debit    :boolean
#  category_id :integer
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Transaction < ActiveRecord::Base
  attr_accessible :description, :date, :amount, :is_debit, :category_id, 
                  :category_name, :skip_category_validation
  belongs_to :user
  belongs_to :category
  before_save :format_amount, :add_time_to_date
  
  validates :description, presence: true, length: { maximum: 255 }
  validates :date, presence: true
  validates :amount, presence: true
  validates_numericality_of :amount
  validate :amount_is_not_zero
  validates_inclusion_of :is_debit, in: [true, false]
  validates :category_id, presence: true, unless: :skip_category_validation
  validates :category_name, presence: true, unless: :skip_category_validation
  validates :user_id, presence: true
  
  def skip_category_validation
    @skip_category_validation
  end
  
  def skip_category_validation=(validation)
    @skip_category_validation = validation
  end
  
  def category_name
   if category.name == 'Uncategorized'
     nil
   else
     category.name
   end
  end
  
  def category_name=(name)
    # category set in controller
  end
  
  # if a user delete's a category for which transactions exist do:
  def category
    if super.nil?
      Category.new(name: "Uncategorized")
    else
      super()
    end
  end
  
  private
  
    def format_amount
      if amount != nil
        if is_debit?
          self.amount = amount.abs * -1
        else
          self.amount = amount.abs
        end
      end
    end
    
    def add_time_to_date
      if date != nil
        now = Time.now
        self.date = date + (now.hour).hour +
                           (now.min).minute +
                           (now.sec).second
      end
    end
    
    def amount_is_not_zero
      self.errors.add(:amount, 'Amount must be a number and non-zero.') if amount == 0
    end
    
end
