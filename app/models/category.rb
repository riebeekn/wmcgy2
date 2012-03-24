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
  attr_accessible :name
  belongs_to :user
  
  validates :name, presence: true 
  validates :user_id, presence: true
  
  default_scope order: 'categories.name' 
end
