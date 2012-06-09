require 'spec_helper'

describe "Users" do
  
  subject { page }
  
  describe "sign up" do
    before { visit signup_path }
    
    describe "items that should be present on sign up page" do
      it { should have_selector('h1', text: 'Sign up') }
      it { should have_field("Email") }
      it { should have_field("Password") }
      it { should have_field("Confirmation") }
      it { should have_button("Sign up") }
      it { should have_selector("title", text: full_title("Sign up")) }
    end
    
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button "Sign up" }.not_to change(User, :count)
        current_path.should == "/users" 
      end
    end
    
    describe "with duplicate email when existing account is active" do
      before do
        FactoryGirl.create(:user, active: true, email: "user@example.com")
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      
      it "should not create a user" do
        expect { click_button "Sign up" }.not_to change(User, :count)
      end
      
      it "should stay on the current page" do
        click_button "Sign up"
        current_path.should == "/users"
      end
      
      it "should display an error" do
        click_button "Sign up"
        page.should have_content("has already been taken")
      end
    end
    
    describe "with duplicate email when existing account is not active" do
      before do
        FactoryGirl.create(:user, active: false, email: "user@example.com")
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      
      it "should not create a user" do
        expect { click_button "Sign up" }.not_to change(User, :count)
      end
      
      it "should redirect to the account activation page" do
        click_button "Sign up"
        current_path.should == account_activation_required_path
      end
      
      it "should display an activation required message" do
        click_button "Sign up"
        page.should have_content("Please activate your account")
      end
    end
    
    describe "with valid information" do
      before do
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end
      
      it "should create a user who has not yet been activated" do
        expect { click_button "Sign up" }.to change(User, :count).by(1) 
        user = User.find_by_email("user@example.com")
        user.should_not be_active
      end
      
      it "should redirect to the sign in page" do
        click_button "Sign up"
        current_path.should == signin_path
      end
      
      it "should display a success message" do
        click_button "Sign up"
        page.should have_content("Sign up complete, check your email")
      end
      
      it "should send an activation email to the user" do
        click_button "Sign up"
        last_email.should_not be_nil 
        last_email.to.should include("user@example.com")
      end
    end
    
    describe "error messages" do
      before { click_button "Sign up" }
      
      it { should have_selector('h1', text: 'Sign up') }
      it { should have_content("can't be blank") }
      it { should have_content("is too short") }
    end
  end
  
end
