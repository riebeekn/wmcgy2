require 'spec_helper'

describe "UserActivations" do
  
  subject { page }
  
  describe "Items on account activation page" do
    before { visit account_activation_required_path }
    
    it { should have_field("Email") }
    it { should have_selector("title", text: full_title("Account activation required"))}
  end
  
  describe "Account activation" do
    describe "When token invalid" do
      before { visit account_activate_path("invalid_token") }
      
      it "renders could not activate page" do
        current_path.should == '/account/account_activation_required'  
      end
      
      it "displays an failure error" do
        page.should have_content("Error occured when activating account, invalid account token")
      end
    end
  
    describe "When token valid" do
      before do
        @user = Factory(:user, activation_token: "token")
        @user.save!
        visit account_activate_path(@user.activation_token)
      end
    
      it "displays a success notification" do
        page.should have_content("Account has been activated")
      end
    
      it "redirects on activation" do
        current_path.should == signin_path
      end
    
      it "activates the  user" do
        visit account_activate_path(@user.activation_token)
        @user.reload
        @user.should be_active
      end
    end
  end
  
  describe "Resend activation email" do
    
    describe "When email is found" do
      it "should send an email" do
        @user = Factory(:user)
        visit account_activation_required_path
        fill_in "Email", with: @user.email
        click_button "Resend activation email"
        page.should have_content("Email sent")
        last_email.should_not be_nil
        last_email.to.should include (@user.email)
        current_path.should == signin_path
      end
    end
    
    describe "When email is not found" do
      it "does not send an email" do
        visit account_activation_required_path
        fill_in "Email", with: "someemail@example.com"
        click_button "Resend activation email"
        page.should have_content("Email sent")
        last_email.should be_nil
        current_path.should == signin_path
      end
    end
  end
end
