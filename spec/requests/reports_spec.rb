require 'spec_helper'

describe "Reports" do
  let(:user) { FactoryGirl.create(:user, active: true) }
  before { sign_in user }
  
  subject { page }
  
  describe "index" do
    describe "items that should be present on the page" do
      before { visit charts_path }
      it { should have_selector("title", text: full_title("Reports")) }
      it { should have_selector("h1", text: "Reports") }
    end
  end
end
