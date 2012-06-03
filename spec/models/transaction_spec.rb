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

require 'spec_helper'

describe Transaction do
  before { @transaction = FactoryGirl.build(:transaction) }
                                  
  subject { @transaction }
  
  it { should respond_to(:description) }
  it { should respond_to(:date) }
  it { should respond_to(:amount) }
  it { should respond_to(:is_debit) }
  it { should respond_to(:user) }
  it { should respond_to(:user_id) }
  it { should respond_to(:category) }
  it { should respond_to(:category_id) }
  it { should be_valid }
  
  describe "when category is nil" do
    before { @transaction.category = nil }
    
    it "should have a category name of 'Uncategorized'" do
      @transaction.category.name.should eq 'Uncategorized'
    end
  end
  
  describe "validations" do
    describe "with blank description" do
      before { @transaction.description = '   ' }
      it { should_not be_valid }
    end
    
    describe "with description that exceeds the maximum length" do
      before { @transaction.description = 'a' * 256  }
      it { should_not be_valid }
    end
    
    describe "with blank date" do
      before { @transaction.date = '  ' }
      it { should_not be_valid }
    end
    
    describe "with blank amount" do
      before { @transaction.amount = '  ' }
      it { should_not be_valid }
    end
    
    describe "with amount of zero" do
      before { @transaction.amount = 0 }
      it { should_not be_valid }
    end
    
    describe "with non numeric amount" do
      before { @transaction.amount = 'foobar' }
      it { should_not be_valid }
    end
    
    describe "with blank is_debit" do
      before { @transaction.is_debit = nil }
      it { should_not be_valid }
    end
    
    describe "when user_id is not present" do
      before { @transaction.user_id = nil }
      it { should_not be_valid }
    end
    
    describe "when user is not present" do
      before { @transaction.user = nil }
      it { should_not be_valid }
    end
    
    describe "when category_id is not present" do
      before { @transaction.category_id = nil }
      it { should_not be_valid }
    end
  end
end
