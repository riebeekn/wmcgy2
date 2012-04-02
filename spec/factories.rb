FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
  end
  
  factory :category do
    name "the category"
    user
  end
  
  factory :transaction do
    sequence(:description)  { |n| "Description #{n}" }
    date Date.today
    amount { 1 + rand(100) }
    is_debit true
    category
    user
  end
end