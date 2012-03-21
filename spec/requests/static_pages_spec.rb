require 'spec_helper'

describe "Static pages" do

  subject { page } 
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }  
  end
  
  describe "Home page" do
    before { visit root_path }
    let(:page_title) { "Home" }
  end
  
  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }
    
    it_should_behave_like "all static pages"
  end
  
  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }
    
    it_should_behave_like "all static pages"
  end
  
  it "should have the right links on the layout" do
    visit contact_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
  end
end
