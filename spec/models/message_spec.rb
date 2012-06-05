require 'spec_helper'

describe Message do
  before { @message = Message.new(name: "Joe Jimmy", email: "j.jimmy@example.com", content: "Howdy") }
  
  subject { @message }
  
  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :content }
  
  describe "validations" do
    
    describe "with blank name is shoud not be valid" do
      before { @message.name = '  ' }
      it { should_not be_valid }
    end
    
    describe "with blank email it should not be valid" do
      before { @message.email = '  ' }
      it { should_not be_valid }
    end
    
    describe "with blank content it should not be valid" do
      before { @message.content = ' ' }
      it { should_not be_valid }
    end
    
    describe "with content that exceeds the maximum length" do
      before { @message.content = 'a' * 501 }
      it { should_not be_valid }
    end
  end
end