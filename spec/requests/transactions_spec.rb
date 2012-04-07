require 'spec_helper'

describe "Transactions" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  before { sign_in user }
  
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
        @credit = FactoryGirl.create(:transaction, date: Date.new(2012, 1, 15), 
          description: 'Pay', amount: 745.6, is_debit: false, user: user, 
          category: @income_category) 
        @debit = FactoryGirl.create(:transaction, date: Date.new(2012, 1, 22), 
          description: 'Groceries', amount: -45.76, is_debit: true, user: user,
          category: @expense_category)
        @oldest_record = FactoryGirl.create(:transaction, date: Date.new(2012, 1, 31),
          user: user) 
      }
      after(:all) { User.destroy_all }
      
      it "should format the credit transaction correctly" do
        page.should have_selector('td', text: '15 Jan 2012')
        page.should have_selector('td', text: 'income')
        page.should have_selector('td', text: 'Pay')
        page.should have_selector('td', text: '$745.60')
      end
      
      it "should format the debit transaction correctly" do
        page.should have_selector('td', text: '22 Jan 2012')
        page.should have_selector('td', text: 'expense')
        page.should have_selector('td', text: 'Groceries')
        page.should have_selector('td', text: '-$45.76')
      end
      
      it "should display all rows" do
        page.should have_selector('tbody//tr', count: 3)
      end
      
      it "should order the posts in reverse chronological order" do
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][0].should have_content('31 Jan 2012')
        rows[1][0].should have_content('22 Jan 2012')
        rows[2][0].should have_content('15 Jan 2012')
      end
            
      describe "it should not display another user's transactions" do
        before(:all) {
          other_user = FactoryGirl.create(:user, active: true)
          other_users_transaction = FactoryGirl.create(:transaction, user: other_user,
            description: 'Some other dudes transaction')
        }
        
        it { should have_selector('tbody//tr', count: 3) }
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
          page.should have_selector('td', text: transaction.date.to_s(:rfc822))
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
        rows[0][0].should have_content('6 Apr 2012')
        rows[1][0].should have_content('5 Apr 2012')
        #re-sort
        click_link 'Date'
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tbody//tr').collect { |row| row.xpath('.//th|td') }
        rows[0][0].should have_content('5 Apr 2012')
        rows[1][0].should have_content('6 Apr 2012')
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
end
