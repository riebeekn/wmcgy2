require "spec_helper"

describe UserMailer do
  describe "activation" do
    let(:user) { FactoryGirl.create(:user, activation_token: "the_activate_token") }
    let(:mail) { UserMailer.activation(user) }

    it "sends the activation email" do
      mail.subject.should eq("Activate your website_name account")
      mail.to.should eq([user.email])
      mail.from.should eq(["from@example.com"])
      mail.body.encoded.should match("http://localhost:3000/account/the_activate_token/activate")
    end
  end
  
  describe "password reset" do
    let(:user) { FactoryGirl.create(:user, password_reset_token: "the_password_token") }
    let(:mail) { UserMailer.password_reset(user) }
    
    it "sends the password reset email" do
      mail.subject.should eq("Password reset")
      mail.to.should eq([user.email])
      mail.from.should eq(["from@example.com"])
      mail.body.encoded.should match("http://localhost:3000/account/the_password_token/reset_password")
    end
  end
end
