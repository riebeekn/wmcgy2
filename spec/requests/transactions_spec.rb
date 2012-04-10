require 'spec_helper'

describe "Transactions" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  
  before do 
    sign_in user 
    @category = FactoryGirl.create(:category, user: user, name: "a category") 
  end
  
  subject { page }
  
  describe "index" do
    before { visit transactions_path }
    
    describe "items that should be present on the page" do
      it { should have_selector('title', text: full_title("Transactions")) }
      it { should have_selector('h1', text: "Transactions")}
    end
     
    describe "it should display the transactions" do
      before(:all) {
        @income_category = FactoryGirl.create(:category, user: user, name: "income")  
        @expense_category = FactoryGirl.create(:category, user: user, name: "expense")  
        @credit = FactoryGirl.create(:transaction, date: 1.day.ago, 
          description: 'Pay', amount: 745.6, is_debit: false, user: user, 
          category: @income_category) 
        @debit = FactoryGirl.create(:transaction, date: 2.days.ago, 
          description: 'Groceries', amount: -45.76, is_debit: true, user: user,
          category: @expense_category)
        @oldest_record = FactoryGirl.create(:transaction, date: 74.hours.ago,
          user: user, description: "the oldest record")
        @older_record = FactoryGirl.create(:transaction, date: 73.hours.ago, user: user,
          description: "almost the oldest record") 
      }
      after(:all) { User.destroy_all }
      
      it "should format the credit transaction correctly" do
        page.should have_selector('td', text: 1.day.ago.strftime('%d %b %Y'))
        page.should have_selector('td', text: 'income')
        page.should have_selector('td', text: 'Pay')
        page.should have_selector('td', text: '$745.60')
      end
      
      it "should format the debit transaction correctly" do
        page.should have_selector('td', text: 2.days.ago.strftime('%d %b %Y'))
        page.should have_selector('td', text: 'expense')
        page.should have_selector('td', text: 'Groceries')
        page.should have_selector('td', text: '-$45.76')
      end
      
      it "should display all rows" do
        page.should have_selector('tbody//tr', count: 4)
      end
      
      it "should order the posts in reverse chronological order" do
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][0].text.should eq(1.days.ago.strftime('%d %b %Y'))
        rows[1][0].text.should eq(2.days.ago.strftime('%d %b %Y'))
        rows[2][0].text.should eq(73.hours.ago.strftime('%d %b %Y'))
        rows[2][2].text.should eq 'almost the oldest record'
        rows[3][0].text.should eq(74.hours.ago.strftime('%d %b %Y'))
        rows[3][2].text.should eq 'the oldest record'
      end
            
      describe "it should not display another user's transactions" do
        before(:all) {
          other_user = FactoryGirl.create(:user, active: true)
          other_users_transaction = FactoryGirl.create(:transaction, user: other_user,
            description: 'Some other dudes transaction')
        }
        
        it { should have_selector('tbody//tr', count: 4) }
        it { should_not have_selector('td', text: 'Some other dudes transaction') }
      end
    end
    
    describe "pagination" do
      # each page has 30 items, create 2 pages of items to test with
      before(:all) { 31.times { FactoryGirl.create(:transaction, user: user) } }
      after(:all) { User.destroy_all }
  
      let(:first_page) { user.transactions.order("date desc").paginate(page: 1) }
      let(:second_page) { user.transactions.order("date desc").paginate(page: 2) }
  
      it { should have_link('Previous') }
      it { should have_link('Next') }
      it { should have_link('2') }
  
      it "should list the first page of transactions" do
        first_page.each do |transaction|
          page.should have_selector('td', text: transaction.date.strftime('%d %b %Y'))
          page.should have_selector('td', text: transaction.category.name)
          page.should have_selector('td', text: transaction.description)
          page.should have_selector('td', text: display_amount(transaction))
        end
        page.should have_selector('tbody//tr', count: 30)
      end
  
      it "should not list the second page of transactions on the first page" do
        second_page.each do |transaction|
          page.should_not have_selector('td', text: transaction.description)
        end
      end
    end
    
    describe "sorting" do
      before(:all) do
        @cat1 = FactoryGirl.create(:category, name: "category a")
        @cat2 = FactoryGirl.create(:category, name: "category b")
        @tran1 = FactoryGirl.create(:transaction, user: user, date: '6 Apr 2012',
                                    category: @cat2, description: "description 1",
                                    amount: 10)
        @tran2 = FactoryGirl.create(:transaction, user: user, date: '5 Apr 2012',
                                    category: @cat1, description: "description 2",
                                    amount: -10)
      end
      after(:all) { User.destroy_all }
      
      it "should default to sorting by date" do
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][0].should have_content('06 Apr 2012')
        rows[1][0].should have_content('05 Apr 2012')
        #re-sort
        click_link 'Date'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][0].should have_content('05 Apr 2012')
        rows[1][0].should have_content('06 Apr 2012')
      end
      
      it "should sort by category when category header clicked" do
        click_link 'Category'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][1].should have_content(@cat1.name)
        rows[1][1].should have_content(@cat2.name)
        # re-sort
        click_link 'Category'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][1].should have_content(@cat2.name)
        rows[1][1].should have_content(@cat1.name)
      end
      
      it "should sort by description when description header clicked" do
        click_link 'Description'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][2].should have_content("description 1")
        rows[1][2].should have_content("description 2")
        click_link 'Description'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][2].should have_content("description 2")
        rows[1][2].should have_content("description 1")
      end
      
      it "should sort by amount when amount header clicked" do
        click_link 'Amount'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][3].should have_content("-$10.00")
        rows[1][3].should have_content("$10.00")
        click_link 'Amount'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][3].should have_content("$10.00")
        rows[1][3].should have_content("-$10.00")
      end
    end
  end
  
  describe "create" do
    before { visit new_transaction_path }
    
    describe "items that should be present on the page" do
      it { should have_selector('title', text: full_title("Add Transaction")) }
      it { should have_selector('h1', text: "Add Transaction") }
      it { should have_selector('label', text: 'Expense') }
      it { should have_selector('label', text: 'Income') }
      it { should have_field('Date') }
      it { should have_field('Category') }
      it { should have_field('Description') }
      it { should have_field('Amount') }
      it { should have_button('Add transaction') }
      
      it "should default date to locale time"
    end
    
    describe "with invalid information" do
      it "should not create a transaction" do
        expect { click_button "Add transaction" }.not_to change(Transaction, :count)
        page.should have_content("can't be blank")
      end
    end
    
    describe "with valid information" do
      before do
        choose  "Expense"
        select "a category", from: "Category"
        fill_in "Description", with: "a description of the transaction"
        fill_in "Amount",      with: "34.56"
      end
      
      it "should create a transaction and re-direct to the main transaction page" do
        expect { click_button "Add transaction" }.to change(Transaction, :count).by(1) 
        page.should have_selector('title', text: full_title("Transaction"))
      end
      
      describe "income transactions" do
        before { choose "Income" }
        
        it "should switch negative amounts to positive amounts" do
          fill_in "Amount", with: -33
          click_button "Add transaction"
          Transaction.last.amount.should eq 33
        end
        
        it "should not switch postive amounts" do
          fill_in "Amount", with: 33
          click_button "Add transaction"
          Transaction.last.amount.should eq 33
        end
      end
      
      describe "expense transactions" do
        it "should switch positive amounts to negative amounts" do
          fill_in "Amount", with: 33
          click_button "Add transaction"
          Transaction.last.amount.should eq -33
        end
        
        it "should not switch negative amounts" do
          fill_in "Amount", with: -33
          click_button "Add transaction"
          Transaction.last.amount.should eq -33
        end
      end 
    end
    
    # need to fix:
        # need to use date time instead of date
    
    # test that date displays local not UTC time by default
  end
end
