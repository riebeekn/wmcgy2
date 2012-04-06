namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    #User.destroy_all
    Rake::Task['db:reset'].invoke   
    make_users
    make_categories
    make_transactions 
  end
end

def make_users
  user = User.create!(email: "example@example.com",
               password: "foobar",
               password_confirmation: "foobar")
  user.toggle!(:active)
end

def make_categories
  user = User.first
  user.categories.create!(name: "Order in Food")
  user.categories.create!(name: "Entertainment")
  user.categories.create!(name: "Pay")
  user.categories.create!(name: "Groceries")
end

def make_transactions
  user = User.first
  categories = Category.all
  100.times do |n|
    description  = Faker::Lorem.sentence
    date = rand(100.days).ago
    amount = (rand * (1 - 200) + 200).round(2)
    category = categories.sample
    is_debit = (category.name != "Pay") #[true, false].sample
    user.transactions.create!(description: description,
                        date: date,
                        amount: amount,
                        is_debit: is_debit,
                        category: category)
  end
end