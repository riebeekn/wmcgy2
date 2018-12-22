require 'spec_helper'

# test class for checking that secured pages can not be accessed without signing in
describe "SecurePages" do

  subject { page }

  describe "home page" do
    it "should prevent access when not signed in" do
      visit root_path
      check_path_and_message(current_path)
    end
  end

  describe "categories" do
    it "should prevent access when not signed in" do
      visit categories_path
      check_path_and_message(current_path)
    end
  end

  describe "budget" do
    it "should prevent access when not signed in" do
      visit budget_path
      check_path_and_message(current_path)
    end
  end

  describe "reports" do
    it "should prevent access when not signed in" do
      visit reports_path
      check_path_and_message(current_path)
    end

    it "should prevent access to expenses data when not signed in" do
      visit reports_expenses_path
      check_path_and_message(current_path)
    end

    it "should prevent access to income data when not signed in" do
      visit reports_income_path
      check_path_and_message(current_path)
    end

    it "should prevent access to income / expense data when not signed in" do
      visit reports_income_and_expense_path
      check_path_and_message(current_path)
    end

    it "should prevent access to profit / loss data when not signed in" do
      visit reports_profit_loss_path
      check_path_and_message(current_path)
    end

  end

  private

    def check_path_and_message(path)
      path.should == signin_path
      page.should have_content("Please sign in")
    end
end
