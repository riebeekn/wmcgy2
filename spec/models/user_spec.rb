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

require 'spec_helper'

describe User do
  
  before { @user = User.new(email: "user@example.com", password: "foobar", 
                            password_confirmation: "foobar") }
                            
  subject { @user }
  
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:auth_token) }
  it { should respond_to(:password_reset_token) }
  it { should respond_to(:password_reset_sent_at) }
  it { should respond_to(:activation_token) }
  it { should respond_to(:activation_sent_at) }
  it { should respond_to(:active) }
  it { should respond_to(:send_activation_email) }
  it { should respond_to(:categories) }
  
  it { should be_valid }
  it { should_not be_active }
  
  describe "with active attribute set to true" do
    before { @user.toggle!(:active) }
    it { should be_active }
  end
  
  describe "validations" do
    
    describe "when email is not present" do
      before { @user.email = "  " }
      it { should_not be_valid }
    end
    
    describe "when email is too long" do
      # max length of an email addy is 254
      before { @user.email = 'a' * 247 + '@foo.com'  }
      it { should_not be_valid }
    end
      
    describe "when email is invalid format" do
      invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      invalid_addresses.each do |invalid_address|
      before { @user.email = invalid_address }
        it { should_not be_valid }
      end
    end
    
    describe "when email format is valid" do
      valid_addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      valid_addresses.each do |valid_address|
        before { @user.email = valid_address }
        it { should be_valid }
      end
    end
    
    describe "when email is already taken" do
      before do
        user_with_same_email = @user.dup
        user_with_same_email.email = @user.email.upcase
        user_with_same_email.save
      end

      it { should_not be_valid }
    end
    
    describe "when password is not present" do
      before { @user.password = "  " } 
      it { should_not be_valid } # validated automatically from has_secure_password
    end
    
    describe "when password confirmation is not present" do
      before { @user.password_confirmation = "  " }
      it { should_not be_valid } # validated automatically from has_secure_password
    end
    
    describe "when password doesn't match confirmation" do
      before { @user.password_confirmation = "mismatch" }
      it { should_not be_valid } # validated automatically from has_secure_password
    end
    
    describe "with a password that's too short" do
      before { @user.password = @user.password_confirmation = 'a' * 5 }
      it { should_not be_valid }
    end

    describe "with a password that's too long" do
      before { @user.password = @user.password_confirmation = 'a' * 41 }
      it { should_not be_valid }
    end
    
    describe "when password digest is empty" do
      before { @user.password_digest = "  " }
      it { should_not be_valid } # validated automatically from has_secure_password
    end
  end 

  describe "send activation email" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "delivers email to user" do
      user.send_activation_email
      last_email.should_not be_nil
      last_email.to.should include(user.email)
    end
    
    it "generates a confirm_sign_up_token" do
      user.send_activation_email
      user.activation_token.should_not be_nil
    end
    
    it "generates a unique confirm_sign_up_token each time" do
      user.send_activation_email
      last_token = user.activation_token
      user.send_activation_email
      user.activation_token.should_not eq(last_token)
    end
    
    it "saves the time the confirm_sign_up_token was sent" do
      user.send_activation_email
      user.reload.activation_sent_at.should be_present
    end
  end
  
  describe "category associations" do
    before do 
      @user_1 = FactoryGirl.create(:user)
      @user_1.save
      @user_2 = FactoryGirl.create(:user)
      @user_2.save
    end
    let!(:category_1) do
      FactoryGirl.create(:category, user: @user_1, name: "Transportation costs")
    end
    let!(:category_2) do
      FactoryGirl.create(:category, user: @user_1, name: "Entertainment")
    end
    let!(:category_3) do
      FactoryGirl.create(:category, user: @user_1, name: "groceries")
    end
    
    it "should have the right categories in the right order" do
      @user_1.categories.should == [category_2, category_3, category_1]
    end
    
    it "should destroy associated categories when user is destroyed" do
      categories = @user_1.categories
      @user_1.destroy
      [category_1, category_2, category_3].each do |category|
        Category.find_by_id(category.id).should be_nil
      end
    end
    
    describe "duplicate categories" do
      it "should not create duplicate categories for the same user" do
        category = @user_1.categories.build(name: "groceries")
        category.should_not be_valid
      end
      
      it "should allow duplicate categories for different users" do
        category = @user_2.categories.build(name: "groceries")
        category.should be_valid
      end
    end
  end
  
  describe "activate" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "activates the user" do
      user.activate
      user.should be_active
    end
  end
end
