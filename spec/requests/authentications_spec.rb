require 'spec_helper'

describe "Authentications" do
  
  subject { page }
  
  # add to this as more secured pages are added to the application
  describe "secured pages redirect the user to sign in when not logged in" do
    
    describe "home page" do
      before { visit root_path }

      it "should redirect when attempting to access home page" do
        current_path.should == signin_path
      end
    
      it { should have_content("Please sign in") }
    end
    
    describe "categories" do
      before { visit categories_path }
      
      it "should redirect when attempting to access categories page" do
        current_path.should == signin_path
      end
    
      it { should have_content("Please sign in") }
    end
  end
  
  describe "sign in" do
    before { visit signin_path }
    
    describe "page contents" do
      it { should have_field("Email") }
      it { should have_field("Password") }
      it { should have_unchecked_field("Remember me") }
      it { should have_button("Sign in") }
      it { should have_link("sign up now!") }
      it { should have_link("Forgot password?") }
      it { should have_selector("title", text: full_title("Sign in")) }
    end
    
    describe "with invalid credentials" do
      before { click_button "Sign in" }
      
      describe "with bad user and bad password" do
        it { should have_content("Invalid email/password combination") }
        it { should have_link("Sign in") }
        it { should_not have_link("Sign out") }
      
        it "should stay on sign in page" do
          current_path.should == '/sessions'
        end
      end
      
      # note need to test this specifically as otherwise could miss the
      # actual authentication step in the implementation
      describe "with valid user but bad password" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          user.password = "bad pwd"
          sign_in user
        end
        
        it { should have_content("Invalid email/password combination") }
        it { should have_link("Sign in") }
        it { should_not have_link("Sign out") }
        
        it "should stay on sign in page" do
          current_path.should == '/sessions'
        end
      end
      
      describe "with user who has not activated their account" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          sign_in user
        end
        
        it { should have_content("Please activate your account") }
        it { should have_link("Sign in") }
        it { should_not have_link("Sign out") }
        
        it "should redirect to account activation page" do
          current_path.should == account_activation_required_path
        end
      end
    end
    
    describe "with valid credentials" do
      let(:user) { FactoryGirl.create(:user, active: true) }
      before do
        sign_in user
      end
      
      it { should have_content("Signed in as #{user.email}")}
      it { should_not have_link("Sign up") }
      it { should_not have_link("Sign in") }
      it { should have_link("Sign out") }
  
      it "should redirect to home page" do
        current_path.should == root_path
      end
    end
  end
  
  describe "sign out" do
    let(:user) { FactoryGirl.create(:user, active: true) }
    before do
      sign_in user
      click_link("Sign out")
    end
    
    it { should have_content("Signed out") }
    it { should have_link("Sign in") }
    it { should_not have_link("Sign out") }
    
    it "should redirect to the sign in page" do
      current_path.should == signin_path
    end
  end
end
