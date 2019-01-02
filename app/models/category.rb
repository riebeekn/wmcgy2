# == Schema Information
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Category < ActiveRecord::Base
  attr_accessible :name, :budgeted, :include_in_budget
  attr_accessor :spent
  belongs_to :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :user_id, presence: true
  validates :name, :uniqueness => { scope: :user_id, case_sensitive: false }
  validates_numericality_of :budgeted

  default_scope order: 'LOWER(categories.name)'
end
