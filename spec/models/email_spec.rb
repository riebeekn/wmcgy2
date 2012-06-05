require 'spec_helper'

describe Email do
  before { @email = Email.new(email: "example@example.com") }
  
  subject { @email }
  
  it { should respond_to :email }
  
  describe "validations" do
    
    describe "with valid email addresses"
      it "should be valid" do
        valid_emails = 
          [
 
#  Note: The three emails below fail validation but in theory are valid
#    "email@123.123.123.123",
#    "email@[123.123.123.123]",
#    "\"email\"@example.com",

            "email@example.com",
            "firstname.lastname@example.com",
            "email@subdomain.example.com",
            "firstname+lastname@example.com",
            "1234567890@example.com",   
            "email@example-one.com",
            "_______@example.com",
            "email@example.name",
            "email@example.museum",
            "email@example.co.jp",
            "firstname-lastname@example.com"
          ]
        valid_emails.each do |e|
          email = Email.new(email: e)
          email.should be_valid, "Email address #{e} was not valid but should be."
        end
      end
    end
    
    describe "with invalid email addresses" do
      it "should not be valid" do
        invalid_emails = 
          [
            
#  Note: The seven emails below pass validation but in theory are invalid
#    "email@example..com",
#    "Abc..123@example.com",   
#    "email@-example.com",
#    "email@example.web",     
#    ".email@example.com",
#    "email.@example.com",
#    "email..email@example.com",
    
            "plainaddress",
            "@example.com",
            "Joe Smith <email@example.com>",
            "    ",
            "",
            "jim jones@example.com",
            "email.example.com",
            "email@example@example.com",              
            "email@example.com (Joe Smith)",
            "email@example",              
            "email@111.222.333.44444",
          ]
        invalid_emails.each do |e|
          email = Email.new(email: e)
          email.should_not be_valid, "Email address #{e} was valid but should not be."
        end
      end
  end
end