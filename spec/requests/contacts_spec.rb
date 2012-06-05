require 'spec_helper'

describe "Contacts" do
  before do
    @email_address_name = "Joe Jipper"
    @email_address_from = "jj@example.com"
    @email_address_body = "Howdy, just wanted to say hi."
    visit new_contact_path
    fill_in "Name", with: @email_address_name
    fill_in "Email", with: @email_address_from
    fill_in "Content", with: @email_address_body
  end
   
  subject { page }
  
  describe "items on page" do
    it { should have_field("Name") }
    it { should have_field("Email") }
    it { should have_field("Content") }
    it { should have_button("Send") }
  end
   
  describe "with invalid information" do   
     
    it "should display error message when name is empty" do
      fill_in "Name", with: " "
      click_button "Send"
      page.should have_content("can't be blank")
    end
     
    it "should display error message when email is blank" do
      fill_in "Email", with: " "
      click_button "Send"
      page.should have_content("is invalid")
    end
     
    it "should display error message when content is blank" do
      fill_in "Content", with: " "
      click_button "Send"
      page.should have_content("can't be blank")
    end
     
    it "should display error message when content is too long" do
      fill_in "Content", with: "a" * 501
      click_button "Send"
      page.should have_content("is too long")
    end
  end
   
  describe "with valid information" do
    it "should send an email" do
      click_button "Send"
      page.should have_content("Message sent")
      last_email.should_not be_nil # note for some reason fails if run test on it's own, passes with full suite
      last_email.from.should include(@email_address_from)
      last_email.subject.should include(@email_address_name)
      last_email.body.should include(@email_address_body)
      current_path.should == new_contact_path
    end
  end
end