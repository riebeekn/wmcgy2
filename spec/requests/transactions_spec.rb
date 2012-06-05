require 'spec_helper'

describe "Transactions" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  
  before do 
    sign_in user 
    @category = FactoryGirl.create(:category, user: user, name: "a category for the user")
    @category2 = FactoryGirl.create(:category, user: user, name: "a second category for the user")
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
      
      it "should have an edit link" do
        visit transactions_path
        should have_link('Edit', href: "/transactions/#{@debit.id}/edit")
      end
      
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
  
  describe "new" do
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
    end
    
    describe "pre-loaded categories" do
      it "should load the user's categories when new transaction page is loaded" do
        document = Nokogiri::HTML(page.body)
        cat = document.xpath('//*[@id="category_names"]/@value')
        cat.inner_html.should have_content @category.name
        cat.inner_html.should have_content @category2.name
      end
      
      it "should load the user's categories after an invalid transaction add attempt" do
        click_button "Add transaction"
        document = Nokogiri::HTML(page.body)
        cat = document.xpath('//*[@id="category_names"]/@value')
        cat.inner_html.should have_content @category.name
        cat.inner_html.should have_content @category2.name
      end
    end
  end
  
  describe "create" do
    before { visit new_transaction_path }
    
    describe "with invalid information" do
      it "should not create a transaction" do
        expect { click_button "Add transaction" }.not_to change(Transaction, :count)
        page.should have_content("can't be blank")
      end
      
      it "should re-populate the categories" do
        click_button "Add transaction"
        document = Nokogiri::HTML(page.body)
        categories = document.xpath('//*[@id="category_names"]/@value')
        categories.should have_content ("a category for the user")
        categories.should have_content("a second category for the user")
      end
      
      it "should re-populate the date with date selected by the user" do
        fill_in "Date", with: 1.day.ago
        click_button "Add transaction"
        document = Nokogiri::HTML(page.body)
        date = document.xpath('//*[@id="transaction_date"]/@value')
        date.inner_html[0,4].should eq (1.day.ago.strftime('%Y'))
        date.inner_html[5,2].should eq (1.day.ago.strftime('%m'))
        date.inner_html[8,2].should eq (1.day.ago.strftime('%d'))
      end
      
      it "should re-populate the amount with the amount entered by the user, with no sign symbol" do
        choose 'Expense'
        fill_in "Amount", with: "35.4"
        click_button "Add transaction"
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('35.40')
      end
      
      it "should handle amounts with dollar signs by stripping the dollar sign" do
        choose 'Expense'
        fill_in "Amount", with: "$35.4"
        click_button "Add transaction"
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('35.40')
      end
    end
    
    describe "with valid information" do
      before do
        choose  "Expense"
        fill_in "Date", with: '11 Apr 2012'
        fill_in "Category", with: "a category"
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
        
        it "should handle dollar signs" do
          fill_in "Amount", with: "$33"
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
  end

  describe "update" do
    before do
      @category = FactoryGirl.create(:category, user: user, name: 'test category')
      @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'A transaction', amount: -234.57, is_debit: true, user: user, 
        category: @category)
    end
    after { User.destroy_all }
    
    describe "with valid information" do
      before do
        visit transactions_path
        click_link 'Edit'
      end
      
      it "should update the transaction and re-direct to the index page" do
        choose  "Income"
        fill_in "Date", with: 2.days.ago
        select "a category", from: "Category"
        fill_in "Description", with: "updated description"
        fill_in "Amount",      with: "$22.33"
        click_button "Edit transaction"
        t = Transaction.find(@transaction.id)
        t.is_debit.should eq false
        t.date.strftime('%d %b %Y %H %M').should eq 2.days.ago.strftime('%d %b %Y %H %M')
        t.description.should eq 'updated description'
        t.amount.should eq 22.33
        page.should have_content 'Transaction updated'
      end
    end
    
    describe "with invalid information" do
      before do
        visit transactions_path
        click_link 'Edit'
        fill_in "Date", with: ''
        select "a category", from: "Category"
        fill_in "Description", with: ""
        fill_in "Amount",      with: ""
      end
      
      it "should re-populate the category" do
        click_button "Edit transaction"
        page.should have_content('test category')
      end
      
      it "should re-populate the amount entered by the user" do
        fill_in "Amount", with: 23.4
        click_button "Edit transaction"
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('23.40')
      end
      
      it "should contain an error message" do
        click_button "Edit transaction"
        page.should have_content("can't be blank")
      end
      
      it "should not update the transaction" do
        click_button "Edit transaction"
        t = Transaction.find(@transaction.id)
        t.is_debit.should eq true
        t.date.to_date.to_s.should eq 1.day.ago.to_date.to_s
        t.description.should eq 'A transaction'
        t.amount.should eq -234.57
      end
    end
  end
  
  describe "edit" do
    describe "expense transaction" do
      before do
        @category = FactoryGirl.create(:category, user: user, name: 'test category')
        @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
          description: 'A transaction', amount: -2343, is_debit: true, user: user, 
          category: @category)
        visit transactions_path
        click_link 'Edit'
      end 
      after { User.destroy_all }
      
      it { should have_checked_field('Expense') }
      it { should have_unchecked_field('Income') }
      
      it "should have a positive amount and two decimal places" do
        # saved as neg. in the DB but should show as positive in the edit form
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('2343.00')
      end
    end
    
    describe "income transaction" do
      before do
        @category = FactoryGirl.create(:category, user: user, name: 'test category')
        @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
          description: 'A transaction', amount: 654.56, is_debit: false, user: user, 
          category: @category)
        visit transactions_path
        click_link 'Edit'
      end
      after { User.destroy_all }
      
      it { should have_unchecked_field('Expense') }
      it { should have_checked_field('Income') }
      
      it "should have a positive amount and two decimal places" do
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('654.56')
      end
    end

    describe "format of output" do
      before do
        @category = FactoryGirl.create(:category, user: user, name: 'test category')
        @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
          description: 'A transaction', amount: 654, is_debit: false, user: user, 
          category: @category)
        visit transactions_path
        click_link 'Edit'
      end
      after { User.destroy_all }
      
      it "should display amount with 2 decimal places" do
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('654.00')
      end
      
      it "should display the date in d mmm yyyy format" do
        document = Nokogiri::HTML(page.body)
        date = document.xpath('//*[@id="transaction_date"]/@value')
        date.inner_html.should eq (1.day.ago.strftime('%d %b %Y'))
      end
    end
    
    describe "items that should be present on the page" do
      before do
        @category = FactoryGirl.create(:category, user: user, name: 'test category')
        @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
          description: 'A transaction', amount: 654.56, is_debit: false, user: user, 
          category: @category)
        visit transactions_path
        click_link 'Edit'
      end
      after { User.destroy_all }
    
      it { should have_selector('title', text: full_title("Edit Transaction")) }
      it { should have_selector('h1', text: "Edit Transaction") }
      it { should have_unchecked_field('Expense') }
      it { should have_checked_field('Income') }
      it { should have_button("Edit transaction") }
      it { should have_link("Cancel")}
      
      it "should display the description" do
        document = Nokogiri::HTML(page.body)
        desc = document.xpath('//*[@id="transaction_description"]/@value')
        desc.inner_html.should eq ('A transaction')
      end
      
      it "should display the date" do
        document = Nokogiri::HTML(page.body)
        date = document.xpath('//*[@id="transaction_date"]/@value')
        date.inner_html.should eq (1.day.ago.strftime('%d %b %Y'))
      end
      
      it "should display the category" do
        cat = find_field('Category').find('option[selected]').text
        cat.should eq('test category')
      end
      
      it "should display the amount" do
        document = Nokogiri::HTML(page.body)
        amt = document.xpath('//*[@id="transaction_amount"]/@value')
        amt.inner_html.should eq ('654.56')
      end
    end
  
    describe "updates" do
      
    end
  end
  
  describe "delete" do
    before(:all) {
      @category = FactoryGirl.create(:category, user: user)
      @transaction = FactoryGirl.create(:transaction, date: 1.day.ago, 
        description: 'Some transaction', amount: 654.56, is_debit: true, user: user, 
        category: @category)
    } 
    after(:all) { User.destroy_all }
    
    it "should have a delete link" do
      visit transactions_path
      should have_link('Delete', href: "/transactions/#{@transaction.id}")
    end
    
    it "should delete the transaction" do
      visit transactions_path
      expect { click_link('Delete') }.to change(Transaction, :count).by(-1)
      page.should have_content('Transaction deleted')
    end
  end
end
