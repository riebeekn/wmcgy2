# == Schema Information
#
# Table name: transactions
#
#  id          :integer         not null, primary key
#  description :string(255)
#  date        :date
#  amount      :decimal(10, 2)  default(0.0)
#  is_debit    :boolean
#  category_id :integer
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Transaction < ActiveRecord::Base
  attr_accessible :description, :date, :amount, :is_debit, :category
  belongs_to :user
  belongs_to :category
  
  validates :description, presence: true, length: { maximum: 255 }
  validates :date, presence: true
  validates :amount, presence: true
  validates_numericality_of :amount
  validates_inclusion_of :is_debit, in: [true, false]
  validates :category_id, presence: true
  validates :user_id, presence: true
  
  default_scope order: 'date DESC' 
end
