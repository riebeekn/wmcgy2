require "spec_helper"

describe ContactMailer do
  describe "contact_us" do
    let(:message) { Message.new( name: "Bob", email: "bob@example.com", content: "This is the body of the email") }
    let(:mail) { ContactMailer.contact_us(message) }

    it "renders the headers" do
      mail.subject.should eq("Contact us email from wmcgy sent by Bob")
      mail.to.should eq(["nick.riebeek@gmail.com"])
      mail.from.should eq(["bob@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("---- Content of message is below ----\r\nThis is the body of the email\r\n----       End of message        ----\r\n")
    end
  end

end
