require 'spec_helper'

describe "Reports" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  before { sign_in user }
  
  subject { page }
  
  describe "index" do
    describe "items that should be present on the page" do
      before { visit reports_path }
      it { should have_selector("title", text: full_title("Reports")) }
      it { should have_selector("h1", text: "Reports") }
    end
  end

  describe "charts" do
    before do
      groceries = FactoryGirl.create(:category, name: "Groceries", user: user)
      pay = FactoryGirl.create(:category, name: "Pay", user: user)
      order_in_food = FactoryGirl.create(:category, name: "Order in food", user: user)
      FactoryGirl.create(:transaction, amount: -23, category: groceries, is_debit: true, user: user,
                                       date: 1.hour.ago)
      FactoryGirl.create(:transaction, amount: -40, category: groceries, is_debit: true, user: user,
                                       date: 2.hours.ago)
      FactoryGirl.create(:transaction, amount: -40, category: order_in_food, is_debit: true, user: user,
                                       date: 3.hours.ago)
      FactoryGirl.create(:transaction, amount: 440, category: pay, is_debit: false, user: user,
                                       date: 4.hours.ago)
    end
  
    describe "expenses" do
      before { visit '/reports/expenses' }
    
      it "should set the static chart elements correctly" do
        page.should have_content('"type":"PieChart"')
        page.should have_content('"cols":[["string","Category"],["number","Amount"]]')
        page.should have_content('"backgroundColor":{"fill":"#F5F5F5"}')
        page.should have_content('"title":"Expenses"')
        page.should have_content('"is3D":true')
        page.should have_content('"titleTextStyle":{"fontSize":18}}')
        page.should have_content('"format_cols":[1]')
      end
    
      it "should show the right data" do
        page.should have_content('"Groceries",63.0]')
        page.should have_content('"Order in food",40.0]')
        page.should_not have_content('"Pay",440.0]')
      end
    end
    
    describe "income" do
      before { visit '/reports/income' }
      
      it "should set the static chart elements correctly" do
        page.should have_content('"type":"PieChart"')
        page.should have_content('"cols":[["string","Category"],["number","Amount"]]')
        page.should have_content('"backgroundColor":{"fill":"#F5F5F5"}')
        page.should have_content('"title":"Income"')
        page.should have_content('"is3D":true')
        page.should have_content('"titleTextStyle":{"fontSize":18}}')
        page.should have_content('"format_cols":[1]')
      end
      
      it "should show the right data" do
        page.should_not have_content('"Groceries",63.0]')
        page.should_not have_content('"Order in food",40.0]')
        page.should have_content('"Pay",440.0]')
      end
    end
    
    describe "income and expense" do
      before { visit '/reports/income_and_expense' }
      
      it "should set the static chart elements correctly" do
        page.should have_content('"type":"LineChart"')
        page.should have_content('"cols":[["string","Month"],["number","Income"],["number","Expenses"]]')
        page.should have_content('"backgroundColor":{"fill":"#F5F5F5"}')
        page.should have_content('"title":"Overall income and expenses"')
        page.should have_content('"titleTextStyle":{"fontSize":18},"pointSize":5}')
        page.should have_content('"format_cols":[1,2]')
      end
      
      it "should have the right data" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",440.0,103.0')
      end
    end
    
    describe "profit loss" do
      before { visit '/reports/profit_loss' }
      
      it "should set the static chart elements correctly" do
        page.should have_content('"type":"ColumnChart"')
        page.should have_content('"cols":[["string","Month"],["number","Profit"],["number","Loss"]]')
        page.should have_content('"backgroundColor":{"fill":"#F5F5F5"}')
        page.should have_content('"title":"Overall profit / loss"')
        page.should have_content('"isStacked":true')
        page.should have_content('"titleTextStyle":{"fontSize":18}}')
        page.should have_content('"format_cols":[1,2]')
      end
      
      it "should have the right data" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",337.0,0')
      end
    end
  end

  describe "when no income entries" do
    before do
      groceries = FactoryGirl.create(:category, name: "Groceries", user: user)
      order_in_food = FactoryGirl.create(:category, name: "Order in food", user: user)
      FactoryGirl.create(:transaction, amount: -23, category: groceries, is_debit: true, user: user,
                                       date: 1.hour.ago)
      FactoryGirl.create(:transaction, amount: -40, category: groceries, is_debit: true, user: user,
                                       date: 2.hours.ago)
      FactoryGirl.create(:transaction, amount: -40, category: order_in_food, is_debit: true, user: user,
                                       date: 3.hours.ago)
      FactoryGirl.create(:transaction, amount: -456.54, category: groceries, is_debit: true, user: user,
                                        date: 1.month.ago)
    end
    
    describe "income and expense" do
      before { visit '/reports/income_and_expense' }
      
      it "should show data for income expense even though only expense entries exist" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",0.0,103.0')
        month = Date::MONTHNAMES[1.month.ago.month][0..2]
        page.should have_content('"' + month + '",0.0,456.54')
      end
    end
    
    describe "profit loss" do
      before { visit '/reports/profit_loss'}
      
      it "should show data for profit loss even though only expense entries exist" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",0,-103.0')
        month = Date::MONTHNAMES[1.month.ago.month][0..2]
        page.should have_content('"' + month + '",0,-456.54')
      end
    end
  end
  
  describe "when no expense entries" do
    before do
      pay = FactoryGirl.create(:category, name: "Pay", user: user)
      FactoryGirl.create(:transaction, amount: 440, category: pay, is_debit: false, user: user,
                                       date: 4.hours.ago)
      FactoryGirl.create(:transaction, amount: 660, category: pay, is_debit: false, user: user,
                                       date: 1.month.ago)
    end
    
    describe "income and expense" do
      before { visit '/reports/income_and_expense' }
      
      it "should show data for income expense even though only income entries exist" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",440.0,0.0')
        month = Date::MONTHNAMES[1.month.ago.month][0..2]
        page.should have_content('"' + month + '",660.0,0.0')
      end
    end
    
    describe "profit loss" do
      before { visit '/reports/profit_loss'}
      
      it "should show data for profit loss even though only income entries exist" do
        month = Date::MONTHNAMES[1.hour.ago.month][0..2]
        page.should have_content('"' + month + '",440.0,0')
        month = Date::MONTHNAMES[1.month.ago.month][0..2]
        page.should have_content('"' + month + '",660.0,0')
      end
    end
  end
end
