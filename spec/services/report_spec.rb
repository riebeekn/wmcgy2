require 'spec_helper'

describe Report do

  describe ".period_value" do
    context "when range is year" do
      it "should return Jan-Dec for periods 1-12" do
        Report.period_value('year', 1).should eq 'Jan'
        Report.period_value('year', 2).should eq 'Feb'
        Report.period_value('year', 3).should eq 'Mar'
        Report.period_value('year', 4).should eq 'Apr'
        Report.period_value('year', 5).should eq 'May'
        Report.period_value('year', 6).should eq 'Jun'
        Report.period_value('year', 7).should eq 'Jul'
        Report.period_value('year', 8).should eq 'Aug'
        Report.period_value('year', 9).should eq 'Sep'
        Report.period_value('year', 10).should eq 'Oct'
        Report.period_value('year', 11).should eq 'Nov'
        Report.period_value('year', 12).should eq 'Dec'
      end
    end

    context "when range is all" do
      it "should return the year passed in" do
        Report.period_value('all', '2011').should eq '2011'
        Report.period_value('all', '2010').should eq '2010'
        Report.period_value('all', '2000').should eq '2000'
        Report.period_value('all', '1901').should eq '1901'
        Report.period_value('all', '1867').should eq '1867'
      end
    end
  end

  describe ".get_value_for_period" do
    let(:test_point_1) { PeriodHelperClass.new('2010', 123) }
    let(:test_point_2) { PeriodHelperClass.new('2011', 324) }
    let(:test_point_3) { PeriodHelperClass.new('2011', 200) }

    it "should return the first value for any matching keys" do
      values = [test_point_1, test_point_2, test_point_3]

      Report.get_value_for_period(values, '2010').should eq 123
      Report.get_value_for_period(values, '2011').should eq 324
    end

    it "should return 0 for any period that is not found" do
      values = [test_point_1]

      Report.get_value_for_period(values, '2012').should eq 0
    end
  end

  describe ".calculate_period" do
    context "year" do
      it "should return an array representing the numerical months from 1 to the end date passed in" do
        a = Report.calculate_period(expenses = [], income = [], 'year', Time.local(2011, 'may', 15))
        a.count.should eq 5
        a[0].should eq 1
        a[1].should eq 2
        a[2].should eq 3
        a[3].should eq 4
        a[4].should eq 5
      end
    end

    context "12" do
      it "should return an array representing the numerical months from the current month to 12 months ago" do
        a = Report.calculate_period(expenses = [], income = [], '12', Time.local(2011, 'may', 15))
        a.count.should eq 12
        a[0].should eq 6
        a[1].should eq 7
        a[2].should eq 8
        a[3].should eq 9
        a[4].should eq 10
        a[5].should eq 11
        a[6].should eq 12
        a[7].should eq 1
        a[8].should eq 2
        a[9].should eq 3
        a[10].should eq 4
        a[11].should eq 5
      end
    end

    context "all" do
      let(:income_record_1) { PeriodHelperClass.new('2009', 12000) }
      let(:income_record_2) { PeriodHelperClass.new('2010', 13000) }
      let(:expense_record_1) { PeriodHelperClass.new('2009', 12000) }
      let(:expense_record_2) { PeriodHelperClass.new('2010', 13000) }

      it "should return the current year if no income or expense records exist" do
        a = Report.calculate_period(expenses = [], income = [], 'all')
        a.count.should eq 1
        a[0].should eq Time.now.year
      end

      it "should include all years covered by income records when income records are earlier than expense records" do
        a = Report.calculate_period(expenses = [expense_record_2], income = [income_record_1, income_record_2], 
                      'all', Time.local(2010, 'may', 3))
        a.count.should eq 2
        a[0].should eq 2009
        a[1].should eq 2010
      end

      it "should include all years covered by expense records when expense records are earlier than income records" do
        a = Report.calculate_period(expenses = [expense_record_1, expense_record_2], income = [income_record_1], 
                      'all', Time.local(2010, 'may', 3))
        a.count.should eq 2
        a[0].should eq 2009
        a[1].should eq 2010
      end
    end
  end

  describe ".calculate_profit_loss" do
    let(:user) { FactoryGirl.create(:user) }

    context "all" do
      it "should return zero for profit / loss when user has no expense or income records" do
        r = Report.calculate_profit_loss("all", user)

        r.count.should eq 1
        r[0][0].should eq "#{Time.now.year}"
        r[0][1].should eq 0
        r[0][2].should eq 0
      end

      it "should return the correct profit / loss values when user has expense and income records" do
        expense_1 = FactoryGirl.create(:transaction, user: user, amount: 20, is_debit: true, date: Time.local(2010, "jan", 15))
        expense_2 = FactoryGirl.create(:transaction, user: user, amount: 40, is_debit: true, date: Time.local(2010, "feb", 23))
        expense_3 = FactoryGirl.create(:transaction, user: user, amount: 100, is_debit: true, date: Time.local(2011, "mar", 13))
        income_1 = FactoryGirl.create(:transaction, user: user, amount: 80, is_debit: false, date: Time.local(2010, "jan", 20))
        income_2 = FactoryGirl.create(:transaction, user: user, amount: 75, is_debit: false, date: Time.local(2011, "feb", 12))

        r = Report.calculate_profit_loss("all", user)

        r[0][0].should eq "2010"
        r[0][1].should eq 20
        r[0][2].should eq 0
        r[1][0].should eq "2011"
        r[1][1].should eq 0
        r[1][2].should eq -25

        index = 1
        for i in 2012..Time.now.year.to_i do
          index += 1
          r[index][0].should eq (i.to_s)
          r[index][1].should eq 0
          r[index][2].should eq 0
        end

        r.count.should eq 2 + (index - 1)
      end
    end

    context "year" do
      it "should return zero for profit / loss when user has no expense or income records" do
        r = Report.calculate_profit_loss("year", user)

        r.count.should eq Time.now.month
        for i in 1..Time.now.month.to_i do
          r[i - 1][0].should eq Date::MONTHNAMES[i][0..2]
          r[i - 1][1].should eq 0
          r[i - 1][2].should eq 0
        end
      end

      it "should return the correct profit / loss values when user has expense and income records" do
        expense_1 = FactoryGirl.create(:transaction, user: user, amount: 20, is_debit: true, date: Time.local(2010, "jan", 15))
        expense_2 = FactoryGirl.create(:transaction, user: user, amount: 40, is_debit: true, date: Time.local(2010, "feb", 23))
        expense_3 = FactoryGirl.create(:transaction, user: user, amount: 100, is_debit: true, date: Time.local(2010, "mar", 13))
        expense_4 = FactoryGirl.create(:transaction, user: user, amount: 50, is_debit: true, date: Time.local(2010, "mar", 14))
        income_1 = FactoryGirl.create(:transaction, user: user, amount: 80, is_debit: false, date: Time.local(2010, "jan", 20))
        income_2 = FactoryGirl.create(:transaction, user: user, amount: 75, is_debit: false, date: Time.local(2010, "feb", 12))
        income_3 = FactoryGirl.create(:transaction, user: user, amount: 200, is_debit: false, date: Time.local(2010, "feb", 15))

        r = Report.calculate_profit_loss("year", user, Time.local("2010", "dec"))

        r.count.should eq 12
        r[0][0].should eq "Jan"
        r[0][1].should eq 60
        r[0][2].should eq 0
        r[1][0].should eq "Feb"
        r[1][1].should eq 235
        r[1][2].should eq 0
        r[2][0].should eq "Mar"
        r[2][1].should eq 0
        r[2][2].should eq -150
        r[3][0].should eq "Apr"
        r[3][1].should eq 0
        r[3][2].should eq 0
        r[4][0].should eq "May"
        r[4][1].should eq 0
        r[4][2].should eq 0
        r[5][0].should eq "Jun"
        r[5][1].should eq 0
        r[5][2].should eq 0
        r[6][0].should eq "Jul"
        r[6][1].should eq 0
        r[6][2].should eq 0
        r[7][0].should eq "Aug"
        r[7][1].should eq 0
        r[7][2].should eq 0
        r[8][0].should eq "Sep"
        r[8][1].should eq 0
        r[8][2].should eq 0
        r[9][0].should eq "Oct"
        r[9][1].should eq 0
        r[9][2].should eq 0
        r[10][0].should eq "Nov"
        r[10][1].should eq 0
        r[10][2].should eq 0
        r[11][0].should eq "Dec"
        r[11][1].should eq 0
        r[11][2].should eq 0
      end
    end
  end

  describe ".calculate_income_expenses" do
    let(:user) { FactoryGirl.create(:user) }

    context "all" do
      it "should return zero for income and expenses when user has no expense or income records" do
        r = Report.calculate_income_expenses("all", user)

        r.count.should eq 1
        r[0][0].should eq "#{Time.now.year}"
        r[0][1].should eq 0
        r[0][2].should eq 0
      end

      it "should return the correct income and expenses when user has expense and income records" do
        expense_1 = FactoryGirl.create(:transaction, user: user, amount: 20, is_debit: true, date: Time.local(2010, "jan", 15))
        expense_2 = FactoryGirl.create(:transaction, user: user, amount: 40, is_debit: true, date: Time.local(2010, "feb", 23))
        expense_3 = FactoryGirl.create(:transaction, user: user, amount: 100, is_debit: true, date: Time.local(2011, "mar", 13))
        income_1 = FactoryGirl.create(:transaction, user: user, amount: 80, is_debit: false, date: Time.local(2010, "jan", 20))
        income_2 = FactoryGirl.create(:transaction, user: user, amount: 75, is_debit: false, date: Time.local(2011, "feb", 12))

        r = Report.calculate_income_expenses("all", user)

        r[0][0].should eq "2010"
        r[0][1].should eq 80
        r[0][2].should eq 60
        r[1][0].should eq "2011"
        r[1][1].should eq 75
        r[1][2].should eq 100

        index = 1
        for i in 2012..Time.now.year.to_i do
          index += 1
          r[index][0].should eq (i.to_s)
          r[index][1].should eq 0
          r[index][2].should eq 0
        end

        r.count.should eq 2 + (index - 1)
      end
    end

    context "year" do
      it "should return zero for income / expenses when user has no expense or income records" do
        r = Report.calculate_income_expenses("year", user)

        r.count.should eq Time.now.month
        for i in 1..Time.now.month.to_i do
          r[i - 1][0].should eq Date::MONTHNAMES[i][0..2]
          r[i - 1][1].should eq 0
          r[i - 1][2].should eq 0
        end
      end

      it "should return the correct income / expenses when user has expense and income records" do
        expense_1 = FactoryGirl.create(:transaction, user: user, amount: 20, is_debit: true, date: Time.local(2010, "jan", 15))
        expense_2 = FactoryGirl.create(:transaction, user: user, amount: 40, is_debit: true, date: Time.local(2010, "feb", 23))
        expense_3 = FactoryGirl.create(:transaction, user: user, amount: 100, is_debit: true, date: Time.local(2010, "mar", 13))
        expense_4 = FactoryGirl.create(:transaction, user: user, amount: 50, is_debit: true, date: Time.local(2010, "mar", 14))
        income_1 = FactoryGirl.create(:transaction, user: user, amount: 80, is_debit: false, date: Time.local(2010, "jan", 20))
        income_2 = FactoryGirl.create(:transaction, user: user, amount: 75, is_debit: false, date: Time.local(2010, "feb", 12))
        income_3 = FactoryGirl.create(:transaction, user: user, amount: 200, is_debit: false, date: Time.local(2010, "feb", 15))

        r = Report.calculate_income_expenses("year", user, Time.local("2010", "dec"))

        r.count.should eq 12
        r[0][0].should eq "Jan"
        r[0][1].should eq 80
        r[0][2].should eq 20
        r[1][0].should eq "Feb"
        r[1][1].should eq 275
        r[1][2].should eq 40
        r[2][0].should eq "Mar"
        r[2][1].should eq 0
        r[2][2].should eq 150
        r[3][0].should eq "Apr"
        r[3][1].should eq 0
        r[3][2].should eq 0
        r[4][0].should eq "May"
        r[4][1].should eq 0
        r[4][2].should eq 0
        r[5][0].should eq "Jun"
        r[5][1].should eq 0
        r[5][2].should eq 0
        r[6][0].should eq "Jul"
        r[6][1].should eq 0
        r[6][2].should eq 0
        r[7][0].should eq "Aug"
        r[7][1].should eq 0
        r[7][2].should eq 0
        r[8][0].should eq "Sep"
        r[8][1].should eq 0
        r[8][2].should eq 0
        r[9][0].should eq "Oct"
        r[9][1].should eq 0
        r[9][2].should eq 0
        r[10][0].should eq "Nov"
        r[10][1].should eq 0
        r[10][2].should eq 0
        r[11][0].should eq "Dec"
        r[11][1].should eq 0
        r[11][2].should eq 0
      end
    end
  end

  describe ".calculate_expense_trend" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      @cat1 = FactoryGirl.create(:category, user: user, name: "Transportation")
      @cat2 = FactoryGirl.create(:category, user: user, name: "Entertainment")
      @cat3 = FactoryGirl.create(:category, user: user, name: "Groceries")
    end

    context "year" do

      it "should return zero trend when user has no expense records" do
        r = Report.calculate_expense_trend("year", user)

        r.count.should eq Time.now.ago(1.month).month
        for i in 1..Time.now.ago(1.month).month.to_i do
          r[i - 1][0].should eq Date::MONTHNAMES[i][0..2]
          r[i - 1][1].should eq nil
          r[i - 1][2].should eq nil
          r[i - 1][3].should eq nil
        end
      end

      it "should return the correct trend when user has expense records" do
        expense_1 = FactoryGirl.create(:transaction, user: user, amount: 20, 
          is_debit: true, date: Time.local(2010, "jan", 15), category: @cat1)
        expense_2 = FactoryGirl.create(:transaction, user: user, amount: 40, 
          is_debit: true, date: Time.local(2010, "feb", 23), category: @cat3)
        expense_3 = FactoryGirl.create(:transaction, user: user, amount: 100, 
          is_debit: true, date: Time.local(2010, "mar", 13), category: @cat3)
        expense_4 = FactoryGirl.create(:transaction, user: user, amount: 50, 
          is_debit: true, date: Time.local(2010, "mar", 14), category: @cat3)
        
        r = Report.calculate_expense_trend("year", user, Time.local("2010", "dec"))

        r[0][0].should eq "Jan"
        r[0][1].should eq 20
        r[0][2].should eq 0
        r[0][3].should eq nil
        r[1][0].should eq "Feb"
        r[1][1].should eq 0
        r[1][2].should eq 40
        r[1][3].should eq nil
        r[2][0].should eq "Mar"
        r[2][1].should eq 0
        r[2][2].should eq 150
        r[2][3].should eq nil
      end
    end
  end

  describe ".period_drop_down_options_for" do
    let(:user) { FactoryGirl.create(:user) }

    it "should return only the default hash when the user has no transactions" do
      dd_options = Report.period_drop_down_options(user)

      dd_options.count.should eq 3
      dd_options.keys.should eq ['year to date', 'last 12 months', 'all']
      dd_options.values.should eq ['year', '12', 'all']
    end

    it "should build a hash of drop down options for years in which the user has transactions" do
       FactoryGirl.create(:transaction, user: user, date: Time.local(2010, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2007, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2011, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2008, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2008, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2008, "jan", 15))
       FactoryGirl.create(:transaction, user: user, date: Time.local(2011, "jan", 15))

       dd_options = Report.period_drop_down_options(user)

       dd_options.count.should eq 7
       dd_options.keys.should eq ['year to date', 'last 12 months', 'all', '2011', '2010', '2008', '2007']
       dd_options.values.should eq ['year', '12', 'all', '2011', '2010', '2008', '2007']
    end
  end
end
