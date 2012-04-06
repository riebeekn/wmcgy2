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
          description: 'Groceries', amount: 45.76, is_debit: true, user: user,
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
  end
end
