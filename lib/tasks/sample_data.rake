namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    Rake::Task['db:reset'].invoke   
    make_users
    make_categories
    make_expenses
    make_rent
    make_income 
  end
end

def make_users
  user = User.create!(email: "example@example.com",
               password: "foobar",
               password_confirmation: "foobar")
  user.toggle!(:active)
  user.name = "example@example.com"
  user.save!
end

def make_categories
  user = User.first
  user.categories.create!(name: "Entertainment")
  user.categories.create!(name: "Groceries")
  user.categories.create!(name: "Misc")
  user.categories.create!(name: "Order in Food")
  user.categories.create!(name: "Pay")
  user.categories.create!(name: "Rent")
  user.categories.create!(name: "Utilities")
  user.categories.create!(name: "Transportation")
  
end

def make_expenses
  user = User.first
  categories = Category.all
  5000.times do |n|
    description  = Faker::Lorem.sentence
    date = rand(3.years).ago
    category = categories.sample
    if category.name == "Pay"
      category = Category.first
    elsif category.name == "Rent"
      category = Category.last
    end
    is_debit = true
    amount = -(rand * (1 - 200) + 200).round(2)
    user.transactions.create!(description: description,
                        date: date,
                        amount: amount,
                        is_debit: is_debit,
                        category_id: category.id)
  end
end

def make_rent
  user = User.first
  category = Category.find_by_name("Rent")
  description = Faker::Lorem.sentence
  for i in 0..35
    user.transactions.create!(description: description,
    date: i.months.ago,
    amount: 1200.00,
    is_debit: 1,
    category_id: category.id)
  end
end

def make_income
  user = User.first
  category = Category.find_by_name("Pay")
  description = Faker::Lorem.sentence
  for i in 0..35
    user.transactions.create!(description: description,
    date: i.months.ago,
    amount: 4356.23,
    is_debit: 0,
    category_id: category.id)
  end
end