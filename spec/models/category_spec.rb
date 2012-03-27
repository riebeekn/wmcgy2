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
    
    describe "when user_id is not present" do
      before { @category.user_id = nil }
      it { should_not be_valid }
    end
    
    describe "duplicates" do
      it "should not allow duplicates" do
        user.save!
        duplicate_category = user.categories.build(name: "some category")
        duplicate_category.should_not be_valid
      end
      
      it "should not allow duplicates that are of a different case" do
        user.save!
        duplicate_category = user.categories.build(name: "SOME category")
        duplicate_category.should_not be_valid
      end
    end
  end
end
