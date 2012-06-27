shared_examples_for 'mtd / ytd widget' do
  it { should have_selector('header', text: 'Current income versus expenses') }
  it { should have_selector('label', text: 'MTD') }
  it { should have_selector('label', text: 'YTD') }
  
  describe "when expenses exceed outcome" do
    before(:all) {
      @income_category = FactoryGirl.create(:category, user: user, name: "income") 
      @expense_category = FactoryGirl.create(:category, user: user, name: "expense")  
      FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'Groceries', amount: -50.76, is_debit: true, user: user,
        category: @expense_category)
      FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'Pay', amount: 10, is_debit: false, user: user, 
        category: @income_category)
      FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year, 
        description: 'Groceries', amount: -500, is_debit: true, user: user,
        category: @expense_category)
      FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year, 
        description: 'Pay', amount: 100, is_debit: false, user: user, 
        category: @income_category)
    }
    after(:all) { User.destroy_all }
    
    it "should show the correct amount for mtd" do
      page.should have_content('-$40.76')
    end
    
    it "should show the correct amount for ytd" do
      page.should have_content('-$440.76')
    end
    
    it "should have the right format" do
      page.should have_selector('span.debit')
      page.should_not have_select('span.credit')
    end
  end
  
  describe "when income exceeds expenses" do
    before(:all) {
      @income_category = FactoryGirl.create(:category, user: user, name: "income") 
      @expense_category = FactoryGirl.create(:category, user: user, name: "expense")  
      FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'Groceries', amount: -50.76, is_debit: true, user: user,
        category: @expense_category)
      FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'Pay', amount: 100, is_debit: false, user: user, 
        category: @income_category)
      FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year, 
        description: 'Groceries', amount: -500, is_debit: true, user: user,
        category: @expense_category)
      FactoryGirl.create(:transaction, date: DateTime.now.beginning_of_year, 
        description: 'Pay', amount: 10000, is_debit: false, user: user, 
        category: @income_category)
    }
    after(:all) { User.destroy_all }
    
    it "should show the correct amount for mtd" do
      page.should have_content('$49.24')
    end
    
    it "should show the correct amount for ytd" do
      page.should have_content('$9,549.24')
    end
    
    it "should have the right format" do
      page.should have_selector('span.credit')
      page.should_not have_select('span.debit')
    end
  end
end