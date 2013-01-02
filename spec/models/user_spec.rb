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

require 'spec_helper'

describe User do
  
  before do 
    @user = User.new(email: "user@example.com", password: "foobar", 
                    password_confirmation: "foobar") 
    @user.should_validate_password = true          
  end
                            
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
  it { should respond_to(:transactions) }
  it { should respond_to(:name) }
  it { should respond_to(:provider) }
  it { should respond_to(:uid) }
  
  it { should be_valid }
  it { should_not be_active }
  
  describe "with active attribute set to true" do
    before { @user.toggle!(:active) }
    it { should be_active }
  end
  
  describe "filters" do
    it "should down-case email on save" do
      email = "JoeJimple@example.com"
      @user.email = email
      @user.save!
       u = User.find_by_email(email.downcase)
       u.should_not be_nil
       u.email.should eq 'joejimple@example.com'
    end
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
    
    describe "when password confirmation is nil" do
      before { @user.password_confirmation = nil }
      it { should_not be_valid }
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

  describe "omniauth" do
    before do
      User.destroy_all
      @uid = "user_id_1"
      @provider = "google_oauth2"
      @name = "Bob"
      @email = "bob@example.com"
      @auth = Hash[
        "provider", @provider,
        "uid", @uid,
        "info", Hash["name", @name, "email", @email]
      ]
    end
    
    context "Google" do  
      it "should create a new user if and return it if user does not exist" do
        expect do
          @user = User.from_omniauth(@auth)
        end.to change(User, :count).by(1)
        @user.should_not be_nil
        @user.email.should eq @email
        @user.name.should eq @name
        @user.uid.should eq @uid
        @user.provider.should eq @provider
        @user.should be_active
      end
      
      it "should return the user if the user already exists and not create a new one" do
        User.from_omniauth(@auth)
        expect do
          @user = User.from_omniauth(@auth)
        end.to_not change(User, :count).by(1)
        @user.should_not be_nil
        @user.email.should eq @email
        @user.name.should eq @name
        @user.uid.should eq @uid
        @user.provider.should eq @provider
        @user.should be_active
      end
    end
    
    context "Twitter" do
      before do
        @provider = "twitter"
        @auth["provider"] = @provider
      end
      
      it "should create a new user if and return it if user does not exist" do
        expect do
          @user = User.from_omniauth(@auth)
        end.to change(User, :count).by(1)
        @user.should_not be_nil
        @user.email.should eq "#{@uid}.no.email.for.twitter@example.com"
        @user.name.should eq @name
        @user.uid.should eq @uid
        @user.provider.should eq @provider
        @user.should be_active
      end
      
      it "should return the user if the user already exists and not create a new one" do
        User.from_omniauth(@auth)
        expect do
          @user = User.from_omniauth(@auth)
        end.to_not change(User, :count).by(1)
        @user.should_not be_nil
        @user.email.should eq "#{@uid}.no.email.for.twitter@example.com"
        @user.name.should eq @name
        @user.uid.should eq @uid
        @user.provider.should eq @provider
        @user.should be_active
      end
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
  
  describe "send password reset email" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "delivers email to user" do
      user.send_password_reset_email
      last_email.should_not be_nil
      last_email.to.should include(user.email)
    end
    
    it "generates a password_reset_token" do
      user.send_password_reset_email
      user.password_reset_token.should_not be_nil
    end
    
    it "generates a unique password reset token each time" do
      user.send_password_reset_email
      last_token = user.password_reset_token
      user.send_password_reset_email
      user.password_reset_token.should_not eq(last_token)
    end
    
    it "saves the time the password reset token was sent" do
      user.send_password_reset_email
      user.reload.password_reset_sent_at.should be_present
    end
  end
  
  describe "activate" do
    let(:user) { FactoryGirl.create(:user) }
    
    it "activates the user" do
      user.activate
      user.should be_active
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

  describe "transaction associations" do
    before do
      @user_1 = FactoryGirl.create(:user)
      @cat_1 = FactoryGirl.create(:category, user: @user_1)
      @trans_1 = FactoryGirl.create(:transaction, category: @cat_1, 
          user: @user_1, date: 1.day.ago)
      @trans_2 = FactoryGirl.create(:transaction, category: @cat_1,
          user: @user_1, date: 1.hour.ago)
    end
    
    it "should have the right transactions" do
      @user_1.transactions.should =~ [@trans_2, @trans_1]
    end
    
    it "should destroy associated transactions when user is destroyed" do
      transactions = @user_1.transactions
      @user_1.destroy
      [@trans_1, @trans_2].each do |transaction|
        Transaction.find_by_id(transaction.id).should be_nil
      end
    end
  end

  describe "mtd / ytd" do
    before do
      @user = FactoryGirl.create(:user, active: true) 
    end
    
    describe "mtd" do
      context "with no transaction" do
        it "should return 0" do
          @user.mtd.should eq 0
        end
      end
      
      context "with transactions" do
        before do
          @cat_pay = FactoryGirl.create(:category, user: @user, name: 'Pay')
          @cat_gro = FactoryGirl.create(:category, user: @user, name: 'Groceries')
          FactoryGirl.create(:transaction, date: 1.day.ago, 
            description: 'A transaction', amount: 50, is_debit: false, user: @user, 
            category: @cat_pay)
          FactoryGirl.create(:transaction, date: 1.day.ago,
            description: 'A transaction', amount: 40, is_debit: true, user: @user,
            category: @cat_gro)
        end
        it "should have the correct mtd value" do
          @user.mtd.should eq 10
        end
      end
    end
  
    describe "ytd" do
      context "with no transactions" do
        it "should return 0" do
          @user.ytd.should eq 0
        end
      end
      
      context "with transactions" do
        before do
          @cat_pay = FactoryGirl.create(:category, user: @user, name: 'Pay')
          @cat_gro = FactoryGirl.create(:category, user: @user, name: 'Groceries')
          FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year, 
            description: 'A transaction', amount: 50000, is_debit: false, user: @user, 
            category: @cat_pay)
          FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year,
            description: 'A transaction', amount: 45000, is_debit: true, user: @user,
            category: @cat_gro)
        end
        
        it "should have the correct ytd value" do
          @user.ytd.should eq 5000
        end
      end
    end
  end
  
  describe "reports" do
    before do
      @user = FactoryGirl.create(:user, active: true) 
      @cat_pay = FactoryGirl.create(:category, user: @user, name: 'Pay')
      @cat_other = FactoryGirl.create(:category, user: @user, name: 'Other')
      @cat_ent = FactoryGirl.create(:category, user: @user, name: 'Entertainment')
      @cat_gro = FactoryGirl.create(:category, user: @user, name: 'Groceries')
      # income
      FactoryGirl.create(:transaction, date: '31 Dec 2012',
        description: 'A transaction', amount: 50, is_debit: false, user: @user, 
        category: @cat_pay)
      FactoryGirl.create(:transaction, date: '31 Dec 2012',
        description: 'A transaction', amount: 25, is_debit: false, user: @user, 
        category: @cat_pay)
      FactoryGirl.create(:transaction, date: '1 Nov 2012',
        description: 'A transaction', amount: 25, is_debit: false, user: @user, 
        category: @cat_pay)
      FactoryGirl.create(:transaction, date: '31 Dec 2012',
        description: 'A transaction', amount: 25, is_debit: false, user: @user, 
        category: @cat_other)
      FactoryGirl.create(:transaction, date: '1 Jan 2010', 
        description: 'A transaction', amount: 25, is_debit: false, user: @user, 
        category: @cat_other)
      # expenses
      FactoryGirl.create(:transaction, date: '31 Dec 2012',
        description: 'A transaction', amount: 1000, is_debit: true, user: @user,
        category: @cat_ent)
      FactoryGirl.create(:transaction, date: '31 Dec 2012',
        description: 'A transaction', amount: 2000, is_debit: true, user: @user,
        category: @cat_gro)
      FactoryGirl.create(:transaction, date: '1 Nov 2012',
        description: 'A transaction', amount: 4000, is_debit: true, user: @user,
        category: @cat_gro)
      FactoryGirl.create(:transaction, date: '1 Jan 2010',
        description: 'A transaction', amount: 1000, is_debit: true, user: @user,
        category: @cat_gro)
    end
    
    describe "income by category and date range" do
      it "should show all transactions when range is empty" do
        income = @user.income_by_category_and_date_range('')
        income[0]["name"].should eq("Pay")
        income[0]["sum"].should eq("100.00")
        income[1]["name"].should eq("Other")
        income[1]["sum"].should eq("50.00")
      end
      
      it "should display the correct items when range is one day ago" do
        range = "31 Dec 2012:TO:31 Dec 2012"
        income = @user.income_by_category_and_date_range(range)
        income[0]["name"].should eq("Pay")
        income[0]["sum"].should eq("75.00")
        income[1]["name"].should eq("Other")
        income[1]["sum"].should eq("25.00")
      end
      
      it "should display the correct items when range is one year ago" do
        range = "01 Jan 2012:TO:31 Dec 2012"
        income = @user.income_by_category_and_date_range(range)
        income[0]["name"].should eq("Pay")
        income[0]["sum"].should eq("100.00")
        income[1]["name"].should eq("Other")
        income[1]["sum"].should eq("25.00")
      end
      
    end
      
    describe "expenses by category and date range" do
      it "should show all transaction when range is empty" do
        expense = @user.expenses_by_category_and_date_range('')
        expense[0]["name"].should eq("Entertainment")
        expense[0]["sum"].should eq("-1000.00")
        expense[1]["name"].should eq("Groceries")
        expense[1]["sum"].should eq("-7000.00")
      end
      
      it "should display the correct items when range is one day ago" do
        range = "31 Dec 2012:TO:31 Dec 2012"
        expense = @user.expenses_by_category_and_date_range(range)
        expense[0]["name"].should eq("Entertainment")
        expense[0]["sum"].should eq("-1000.00")
        expense[1]["name"].should eq("Groceries")
        expense[1]["sum"].should eq("-2000.00")
      end
      
      it "should display the correct items when range is one year" do
        range = "01 Jan 2012:TO:31 Dec 2012"
        expense = @user.expenses_by_category_and_date_range(range)
        expense[0]["name"].should eq("Entertainment")
        expense[0]["sum"].should eq("-1000.00")
        expense[1]["name"].should eq("Groceries")
        expense[1]["sum"].should eq("-6000.00")
      end
    end
  
    describe "income by year" do
      it "should display the correct items" do
        income = @user.income_by_year
        year_as_number_for_first_record = "2010"
        income[0]["period"].should eq(year_as_number_for_first_record)
        income[0]["sum"].should eq("25.00")
        year_as_number_for_second_record = "2012"
        income[1]["period"].should eq(year_as_number_for_second_record)
        income[1]["sum"].should eq("125.00")
      end
    end
    
    describe "income by month for current year" do
      it "should display the correct items" do
        income = @user.income_by_month_for_current_year(2012)
        month_as_number_for_first_record = "11"
        income[0]["period"].should eq(month_as_number_for_first_record)
        income[0]["sum"].should eq("25.00")
        month_as_number_for_second_record = "12"
        income[1]["period"].should eq(month_as_number_for_second_record)
        income[1]["sum"].should eq("100.00")
      end
    end
    
    describe "expenses by year" do
      it "should display the correct items" do
        expenses = @user.expenses_by_year
        year_as_number_for_first_record = "2010"
        expenses[0]["period"].should eq(year_as_number_for_first_record)
        expenses[0]["sum"].should eq("-1000.00")
        year_as_number_for_second_record = "2012"
        expenses[1]["period"].should eq(year_as_number_for_second_record)
        expenses[1]["sum"].should eq("-7000.00")
      end
    end
    
    describe "expenses by month for current year" do
      it "should display the correct items" do
        expenses = @user.expenses_by_month_for_current_year(2012)
        month_as_number_for_first_record = "11"
        expenses[0]["period"].should eq(month_as_number_for_first_record)
        expenses[0]["sum"].should eq("-4000.00")
        month_as_number_for_second_record = "12"
        expenses[1]["period"].should eq(month_as_number_for_second_record)
        expenses[1]["sum"].should eq("-3000.00")
      end
    end
  end
end
 
