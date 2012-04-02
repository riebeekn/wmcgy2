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

require 'spec_helper'

describe Category do
  let(:user) { FactoryGirl.create(:user) }
  before { @category = user.categories.build(name: "some category") }
  
  subject { @category }
  
  it { should respond_to :name }
  it { should respond_to :user_id }
  it { should respond_to :user }
  it { should be_valid}
  
  describe "validations" do
    
    describe "with blank name" do
      before { @category.name = "  " }
      it { should_not be_valid }
    end
    
    describe "with name that exceeds the maximum length" do
      before { @category.name = 'a' * 256 }
      it { should_not be_valid }
    end
    
    describe "when user_id is not present" do
      before { @category.user_id = nil }
      it { should_not be_valid }
    end
    
    describe "duplicate category names for the same user" do
      before do 
        user.save!
        @category_2 = user.categories.build(name: @category.name.upcase) 
      end
      subject { @category_2 }
      it { should_not be_valid }
    end
    
    describe "duplicate category names for different users" do
      let(:user_2) { FactoryGirl.create(:user) }
      before do
        user.save!
        @category_2 = user_2.categories.build(name: @category.name) 
      end
      
      subject { @category_2 } 
      
      it { should be_valid }
    end
  end
end
