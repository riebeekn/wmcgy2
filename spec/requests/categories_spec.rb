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
        @cat1 = user.categories.build(name: "rent")
        @cat1.save!
        @cat2 = user.categories.build(name: "Groceries")
        @cat2.save!
        @cat3 = user.categories.build(name: "Entertainment")
        @cat3.save!
        visit categories_path
      end
      
      it { should_not have_content("Use this page to") }
      it { should have_selector("tr", count:3) }
      
      it "should order the categories in alphabetical order ignoring case" do
        document = Nokogiri::HTML(page.body)
        rows = document.xpath('//table//tr').collect { |row| row.xpath('.//th|td') }
       
        rows[0][0].should have_content("Entertainment")
        rows[0][1].should have_link("Edit", href: "#")
        find(:xpath, "//a[@id='" + @cat3.id.to_s + "']")
        rows[0][2].should have_link("Delete")
       
        rows[1][0].should have_content("Groceries")
        rows[1][1].should have_link("Edit", href: "#")
        find(:xpath, "//a[@id='" + @cat2.id.to_s + "']")
        rows[1][2].should have_link("Delete")
       
        rows[2][0].should have_content("rent")
        rows[2][1].should have_link("Edit", href: "#")
        find(:xpath, "//a[@id='" + @cat1.id.to_s + "']")
        rows[2][2].should have_link("Delete")
      end
    end
  end
  
  describe "create" do
    before { visit categories_path }
    
    describe "with a blank category" do
      before { click_button "Add" }
      
      it { should have_content "Category can't be blank" }
      
      it "should stay on the category page" do
        current_path.should == categories_path
      end
    end
    
    describe "with a valid category" do
      before do
        fill_in "category[name]", with: "a new category"
      end
      
      it "should display the new category" do
        expect do
          click_button "Add"
        end.to change(Category, :count).by(1)
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
      
      it "should display an error message" do
        page.should have_content("Category already exists")
      end
    end
  end
  
  describe "delete" do
    before do
      visit categories_path
      fill_in "category[name]", with: "a new category"
      click_button "Add"
      page.should have_selector("tr", text: "a new category")
    end
    
    it "should decrement the cateory count and remove the category from the UI" do
      expect do
        click_link "Delete"
      end.to change(Category, :count).by(-1)
      page.should_not have_selector("tr", "a new category")
    end
    
    it "should display a message" do
      click_link "Delete"
      page.should have_content("Category removed")
    end
  end
  
  describe "update" do
    before do
      visit categories_path
      fill_in "category[name]", with: "a new category"
      click_button "Add"
      page.should have_selector("tr", text: "a new category")
    end
    
    it "should update the name of the category" do
      click_link "Edit"
      fill_in "category[name]", with: "an updated category"
      click_button "Add" # click the add btn to change focus and save the edit
      page.should have_selector("tr", text: "an updated category")
    end
    
    it "should not update the category name if the name is changed to blank" do
      click_link "Edit"
      fill_in "category[name]", with: "   "
      click_button "Add" # click the add btn to change focus and save the edit
      page.should have_selector("tr", text: "a new category")
    end
  end
end
