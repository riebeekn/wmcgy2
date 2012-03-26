require 'spec_helper'

describe "Categories" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  before { sign_in user }
  
  subject { page }
  
  describe "index" do
    
    describe "items that should be present on the page" do
      before { visit categories_path }
      it { should have_selector("title", text: full_title("Categories")) }
      it { should have_selector("h1", text: "Categories") }
      it { should have_button("Add") }
      it { should have_field("category[name]") }
    end
    
    describe "when no categories have been created" do
      before { visit categories_path }
      it { should have_content("Use this page to") }
    end
    
    describe "when categories have been created" do
      before do
        user.categories.build(name: "Groceries").save!
        user.categories.build(name: "Entertainment").save!
        visit categories_path
      end
      
      it { should_not have_content("Use this page to") }
      it { should have_content("Groceries") }
      it { should have_content("Entertainment") }
    end
    
  end
  
  describe "create" do
    before { visit categories_path }
    
    describe "with a blank category" do
      before { click_button "Add" }
      
      it { should have_content "Name can't be blank" }
      
      it "should stay on the category page" do
        current_path.should == categories_path
      end
    end
    
    describe "with a valid category" do
      before do
        fill_in "category[name]", with: "a new category"
        click_button "Add"
      end
      
      it "should display the new category" do
        page.should have_selector("tr", text: "a new category")
      end
    end
    
    describe "with a duplicate category" do
      before do
        fill_in "category[name]", with: "a new category"
        click_button "Add"
        fill_in "category[name]", with: "a new category"
        click_button "Add"
      end
      
      #it "should display an error message" do
      #  page.should have_content("duplicate")
      #end
    end
  end
end
