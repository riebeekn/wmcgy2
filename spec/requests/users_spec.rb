require 'spec_helper'

describe "Users" do
  
  subject { page }
  
  describe "edit account" do
    let(:user) { FactoryGirl.create(:user, active: true) }
    before do 
      sign_in user 
      visit account_path
    end
    
    describe "items that should be present on page" do
      it { should have_selector('h1', text: 'Account Settings') }
      # change email section
      it { should have_selector('header', text: 'Change email') }
      it { should have_field('Email', with: user.email) }
      it { should have_button('Update email') }
      #change password section
      it { should have_selector('header', text: 'Change password') }
      it { should have_field('Old password') }
      it { should have_field('New password') }
      it { should have_field('Confirm new password') }
      it { should have_button('Update password') }
      it { should have_link('Forgot password') }
      #delete account section
      it { should have_selector('header', text: 'Delete account') }
      it { should have_content('Account deletion cannot be undone, please be certain.') }
      it { should have_button('Delete account') }
      
      context "mtd / ytd widget" do
       it_behaves_like 'mtd / ytd widget'
      end
    end
    
    describe "change email" do
      
      context "valid email" do
        before do
          fill_in "Email", with: "a.new.email@example.com"
          click_button "Update email"
        end
        
        it "should update the user's email" do  
          User.find(user).email.should eq "a.new.email@example.com"
        end
        
        it "should display a message that the email was updated" do
          page.should have_content "Email updated"
        end
      end
      
      context "invalid email" do
        it "should not update the user's email when email has already been taken" do
          FactoryGirl.create(:user, email: "a.popular.email@example.com")
          fill_in "Email", with: "a.popular.email@example.com"
          click_button "Update email"
          page.should_not have_content "Signed in as a.popular.email@example.com"
          page.should have_content "has already been taken"
        end
      
        it "should not update the user's email if blank" do
          fill_in "Email", with: "    "
          click_button "Update email"
          page.should have_content "can't be blank"
          page.should_not have_content "Signed in as    "
          User.find(user.id).email.should_not eq ""
        end
        
        it "should not update the user's email if format is invalid" do
          fill_in "Email", with: "a bad email"
          click_button "Update email"
          page.should have_content "is invalid"
          page.should_not have_content "Signed in as a bad email"
          User.find(user.id).email.should_not eq "a bad email"
        end
      end
    end
    
    describe "change password" do
      
      context "valid information" do
        before do
          fill_in "Old password", with: "foobar"
          fill_in "New password", with: "foobar2"
          fill_in "Confirm new password", with: "foobar2"
        end
        
        it "should change the password digest" do
          original_digest = User.find(user).password_digest
          click_button "Update password"
          User.find(user).password_digest.should_not eq original_digest
        end
        
        it "should display a message that the password was updated" do
          click_button "Update password"
          page.should have_content "Password updated"
        end
      end
      
      context "invalid information" do
        before do
          @original_digest = User.find(user).password_digest
        end
        
        context "incorrect old password" do
          before do
            fill_in "Old password", with: "barbaz"
            fill_in "New password", with: "foobar2"
            fill_in "Confirm new password", with: "foobar2"
            click_button "Update password"
          end
          
          it "should not update password digest" do  
            User.find(user).password_digest.should eq @original_digest
          end
        
          it "should display a message" do
            page.should have_content "incorrect old password"
          end
        end
        
        context "invalid new password" do
          before do
            fill_in "Old password", with: "foobar"
            fill_in "New password", with: "a"
            fill_in "Confirm new password", with: "a"
            click_button "Update password"
          end
          
          it "should not update password digest" do  
            User.find(user).password_digest.should eq @original_digest
          end
          
          it "should display a message" do
            page.should have_content "is too short (minimum is 6 characters)"
          end
        end
        
        context "mis-matching new password and new password confirmation" do
          before do
            fill_in "Old password", with: "foobar"
            fill_in "New password", with: "barbaz"
            fill_in "Confirm new password", with: "barbax"
            click_button "Update password"
          end
          
          it "should not update password digest" do  
            User.find(user).password_digest.should eq @original_digest
          end
          
          it "should display a message" do
            page.should have_content "doesn't match confirmation"
          end
        end
      end
    end
    
    describe "delete user" do
      before do
        click_button "Delete account"
      end
      
      it "should delete the user" do
        email = user.email
        User.find_by_email(email).should be_nil
      end
      
      it "should re-direct to the sign-in page" do
        current_path.should eq signin_path
      end
      
      it "should display an account deleted message" do
        page.should have_content("Account closed")
      end
    end
  end
  
  describe "sign up" do
    before { visit signup_path }
    
    describe "items that should be present on sign up page" do
      it { should have_selector('h1', text: 'No account?') }
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
      
      it { should have_selector('h1', text: 'No account?') }
      it { should have_content("can't be blank") }
      it { should have_content("is too short") }
    end
  end
  
end
