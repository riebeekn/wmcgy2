require 'spec_helper'

describe "Budget" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  before { sign_in user }

  subject { page }

  describe "index" do

    describe "items that should be present on the page" do
      before { visit budget_path }
      it { should have_selector("title", text: full_title("Budget")) }
      it { should have_selector("h1", text: "Budget") }
    end

    context "mtd / ytd widget" do
      before { visit budget_path }
      it_behaves_like 'mtd / ytd widget'
    end

    describe "when no categories have been created" do
      before { visit budget_path }
      it { should have_content("You need to create some categories") }
    end

    describe "when categories have been created" do
      before do
        user.categories.build(name: "Rent", budgeted: 800).save!
        user.categories.build(name: "Groceries", budgeted: 500).save!
        user.categories.build(name: "Entertainment", budgeted: 200).save!
        visit budget_path
      end

      it { should_not have_content("You need to create some categories") }
      it "should order the categories in alphabetical order ignoring case" do
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tr').collect { |row| row.xpath('.//th|td') }

        rows[0][0].should have_content("Entertainment")
        rows[0][1].should have_content("$200.00")

        rows[1][0].should have_content("Groceries")
        rows[1][1].should have_content("$500.00")

        rows[2][0].should have_content("Rent")
        rows[2][1].should have_content("$800.00")
      end
    end
  end
end
