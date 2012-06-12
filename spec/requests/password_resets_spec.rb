require 'spec_helper'

describe "PasswordResets" do
  
  subject { page }
  
  describe "reset password page" do
    
    describe "GET" do
      describe "when reset password token is invalid" do
      before { visit reset_password_path("bad_token") }
      
      it "redirects to forgot password page" do
        current_path.should == forgot_password_path
      end
      
      it "displays a notice indicating the token was invalid" do
        page.should have_content("Invalid password reset token")
      end
    end
      
      describe "when reset password token is valid but user is not active" do
      before do
        @user = FactoryGirl.create(:user, active: false, password_reset_token: "psToken")
        visit reset_password_path("psToken")
      end
      
      it "should redirect to account activation" do
        current_path.should == account_activation_required_path
      end
    end
    
      describe "when reset password token is valid" do
      before do
        @user = FactoryGirl.create(:user, active: true, password_reset_token: "psToken",
          password_reset_sent_at: 1.hour.ago)
        visit reset_password_path("psToken")
      end

      it { should have_field("New password") }
      it { should have_field("Confirmation") }
      it { should have_button("Update Password") }
      
      describe "validations" do
        describe "when password and password confirmation do not match" do
        before do
          fill_in "New password", with: "new_pass"
          fill_in "Confirmation", with: "mismatch"
          click_button "Update Password"
        end
        
        it "should re-render the page" do
          current_path.should == update_password_path("psToken")
        end
        
        it "should display an error message" do
          page.should have_content("doesn't match")
        end
        
      end
      
        describe "when password and password confirmation are too short" do
        before do
          fill_in "New password", with: "pwd"
          fill_in "Confirmation", with: "pwd"
          click_button "Update Password"
        end
        
        it "should re-render the page" do
          current_path.should == update_password_path("psToken")
        end
        
        it "should display an error message" do
          page.should have_content("too short")
        end
      end
      
        describe "when password and password confirmation are empty" do
        before do
          fill_in "New password", with: ""
          fill_in "Confirmation", with: ""
          click_button "Update Password"
        end
        
        it "should re-render the page" do
          current_path.should == update_password_path("psToken")
        end
        
        it "should display an error message" do
          page.should have_content("too short")
        end
      end
      end
    end
    end
    
    describe "POST" do
      before do
        @user = FactoryGirl.create(:user, active: true, password_reset_token: "pswdToken",
                               password_reset_sent_at: 2.hours.ago)
        @user.save!
        visit reset_password_path("pswdToken")
        fill_in "New password", with: "new password"
        fill_in "Confirmation", with: "new password"
        
      end

      describe "when user is not active" do
        before do
          @user.active = false
          @user.save!
          click_button "Update Password"
        end
        
        it "redirects to the activate user page" do
          current_path.should == account_activation_required_path
        end
      end
      
      describe "when user is not found with the passed in token" do
        before do
          @user.password_reset_token = "badToken"
          @user.save!
          click_button "Update Password"
        end
        
        it "should redirect to forgot password page" do
          current_path.should == forgot_password_path
        end
        
        it "should display a message" do
          page.should have_content("Invalid password")
        end
      end
      
      describe "when reset password token has expired" do
        before { click_button "Update Password" }
        
        it "redirects to forgot password page" do
          current_path.should == forgot_password_path
        end

        it "displays a password token expired message" do
          page.should have_content("Password reset has expired.")
        end
      end
    end
  end
  
  describe "forgot password page" do
    let(:user) { FactoryGirl.create(:user, active: true) }
    before { visit forgot_password_path }
    
    it { should have_field("Email") }
    it { should have_button("Send password reset email") }
    it { should have_selector("title", text: full_title("Forgot password")) }
    
    describe "when email is found and user is active" do
      before do
        fill_in "Email", with: user.email
        click_button "Send password reset email"
      end
      
      it "sends an email" do  
        last_email.should_not be_nil
        last_email.to.should include(user.email)
      end
      
      it "redirects to the root sign in page" do
        current_path.should == signin_path
      end
      
      it "displays an email sent message" do
        page.should have_content("Check your email for instructions on how to reset your password.")
      end
    end
    
    describe "when email is found and user is not active" do
      let(:inactive_user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email", with: inactive_user.email
        click_button "Send password reset email"
      end
      
      it "does not send an email" do
        last_email.should be_nil
      end
      
      it "should redirect to account activation" do
        current_path.should == account_activation_required_path
      end
      
      it { should have_content("Your account has not been activated") }
    end
    
    describe "when email is not found" do
      it "does not send an email" do
        fill_in "Email", with: "wrong.email@example.com"
        click_button "Send password reset email"
        last_email.should be_nil
      end
    end
    
    describe "when email is invalid" do
      before do
        fill_in "Email", with: "  "
        click_button "Send password reset email"
      end
      
      it "stays on the current page" do
        current_path.should == password_resets_path
      end
      
      it "displays validation messages" do
        page.should have_content("is invalid")
      end
      
      it "does not send an email" do
        last_email.should be_nil
      end
    end
  end
end
