shared_examples_for 'budget status widget' do

  describe "with no transactions" do
    it "should show the correct status" do
      page.should have_content('ON BUDGET')
    end

    it "should have the right class" do
      page.should have_css('header.credit')
    end
  end

  describe "when over budget" do
    before(:all) {
      @cat = FactoryGirl.create(:category, user: user, name: "Rent", budgeted: 800)
      FactoryGirl.create(:transaction, date: 1.hour.ago,
        description: 'A transaction', amount: 801, is_debit: true, user: user,
        category: @cat)
    }
    after(:all) { User.destroy_all }

    it "should show the correct status" do
      page.should have_content('OVER BUDGET')
    end

    it "should have the right class" do
      page.should have_css('header.debit')
    end
  end

  describe "when under budget" do
    before(:all) {
      @cat = FactoryGirl.create(:category, user: user, name: "Rent", budgeted: 800)
      FactoryGirl.create(:transaction, date: 1.hour.ago,
        description: 'A transaction', amount: 799, is_debit: true, user: user,
        category: @cat)
    }
    after(:all) { User.destroy_all }

    it "should show the correct status" do
      page.should have_content('ON BUDGET')
    end

    it "should have the right class" do
      page.should have_css('header.credit')
    end
  end
end
